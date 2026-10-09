import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/constants/api_endpoints.dart';
import 'package:zukkor/core/network/auth_interceptor.dart';
import 'package:zukkor/core/storage/token_storage.dart';

/// A simple in-memory [TokenStorage] — no secure-storage plugin involved.
class _FakeTokenStorage implements TokenStorage {
  String? access;
  String? refresh;
  int clearCalls = 0;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({required String access, String? refresh}) async {
    this.access = access;
    if (refresh != null) this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    access = null;
    refresh = null;
  }
}

/// Serves canned responses by path, with no real socket involved — the
/// standard way to exercise a Dio interceptor's full request/response
/// pipeline (so `onError`'s 401 branch actually fires the way Dio fires
/// it in production) without a real backend.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode, Map<String, dynamic> data) =>
    ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Dio _dio(FutureOr<ResponseBody> Function(RequestOptions options) handler) =>
    Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _FakeAdapter(handler);

void main() {
  late _FakeTokenStorage storage;
  late int sessionExpiredCalls;
  void onSessionExpired() => sessionExpiredCalls++;

  setUp(() {
    storage = _FakeTokenStorage();
    sessionExpiredCalls = 0;
  });

  test(
    'adds an Authorization header to a protected request when an access token exists',
    () async {
      storage.access = 'tok-1';
      String? receivedAuth;
      final Dio dio =
          _dio((options) {
              receivedAuth = options.headers['Authorization'] as String?;
              return _json(200, {'ok': true});
            })
            ..interceptors.add(
              AuthInterceptor(
                tokenStorage: storage,
                onSessionExpired: onSessionExpired,
              ),
            );

      await dio.get<dynamic>('/protected/ping');

      expect(receivedAuth, 'Bearer tok-1');
    },
  );

  test(
    'does not add an Authorization header to a public (auth) path even when a token exists',
    () async {
      storage.access = 'tok-1';
      String? receivedAuth;
      final Dio dio =
          _dio((options) {
              receivedAuth = options.headers['Authorization'] as String?;
              return _json(200, {'ok': true});
            })
            ..interceptors.add(
              AuthInterceptor(
                tokenStorage: storage,
                onSessionExpired: onSessionExpired,
              ),
            );

      await dio.post<dynamic>(ApiEndpoints.login);

      expect(receivedAuth, isNull);
    },
  );

  test(
    'sends no Authorization header when no access token is stored',
    () async {
      storage.access = null;
      String? receivedAuth;
      final Dio dio =
          _dio((options) {
              receivedAuth = options.headers['Authorization'] as String?;
              return _json(200, {'ok': true});
            })
            ..interceptors.add(
              AuthInterceptor(
                tokenStorage: storage,
                onSessionExpired: onSessionExpired,
              ),
            );

      await dio.get<dynamic>('/protected/ping');

      expect(receivedAuth, isNull);
    },
  );

  test(
    'a 401 refreshes the token once and retries the original request with it',
    () async {
      storage.access = 'old-access';
      storage.refresh = 'old-refresh';
      int pingCalls = 0;
      int refreshCalls = 0;
      String? authOnRetry;

      FutureOr<ResponseBody> handler(RequestOptions options) {
        if (options.path == ApiEndpoints.tokenRefresh) {
          refreshCalls++;
          return _json(200, {
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          });
        }
        pingCalls++;
        if (pingCalls == 1) {
          return _json(401, {'detail': 'expired'});
        }
        authOnRetry = options.headers['Authorization'] as String?;
        return _json(200, {'ok': true});
      }

      final Dio refreshDio = _dio(handler);
      final Dio dio = _dio(handler)
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            onSessionExpired: onSessionExpired,
            refreshDio: refreshDio,
          ),
        );

      final Response<dynamic> response = await dio.get<dynamic>(
        '/protected/ping',
      );

      expect(response.statusCode, 200);
      expect(refreshCalls, 1);
      expect(authOnRetry, 'Bearer new-access');
      // The backend always rotates the refresh token too — both must be
      // persisted, not just the access token.
      expect(storage.access, 'new-access');
      expect(storage.refresh, 'new-refresh');
      expect(sessionExpiredCalls, 0);
    },
  );

  test(
    'a 401 with no refresh token stored expires the session without calling refresh',
    () async {
      storage.access = 'old-access';
      storage.refresh = null;
      int refreshCalls = 0;

      FutureOr<ResponseBody> handler(RequestOptions options) {
        if (options.path == ApiEndpoints.tokenRefresh) {
          refreshCalls++;
          return _json(200, {'access_token': 'x', 'refresh_token': 'y'});
        }
        return _json(401, {'detail': 'expired'});
      }

      final Dio dio = _dio(handler)
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            onSessionExpired: onSessionExpired,
          ),
        );

      await expectLater(
        dio.get<dynamic>('/protected/ping'),
        throwsA(isA<DioException>()),
      );

      expect(refreshCalls, 0);
      expect(sessionExpiredCalls, 1);
      expect(storage.clearCalls, 1);
    },
  );

  test(
    'a 401 where the refresh request itself fails expires the session and surfaces the original error',
    () async {
      storage.access = 'old-access';
      storage.refresh = 'old-refresh';
      int refreshCalls = 0;

      FutureOr<ResponseBody> handler(RequestOptions options) {
        if (options.path == ApiEndpoints.tokenRefresh) {
          refreshCalls++;
          return _json(401, {'detail': 'refresh token invalid'});
        }
        return _json(401, {'detail': 'expired'});
      }

      final Dio refreshDio = _dio(handler);
      final Dio dio = _dio(handler)
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            onSessionExpired: onSessionExpired,
            refreshDio: refreshDio,
          ),
        );

      await expectLater(
        dio.get<dynamic>('/protected/ping'),
        throwsA(isA<DioException>()),
      );

      expect(refreshCalls, 1);
      expect(sessionExpiredCalls, 1);
      expect(storage.clearCalls, 1);
    },
  );

  test(
    'QueuedInterceptor guarantee: N concurrent 401s trigger exactly one refresh, '
    'and every request completes with the new token',
    () async {
      storage.access = 'old-access';
      storage.refresh = 'old-refresh';
      int refreshCalls = 0;
      final Map<String, int> callsByPath = {};

      FutureOr<ResponseBody> handler(RequestOptions options) {
        if (options.path == ApiEndpoints.tokenRefresh) {
          refreshCalls++;
          // A real refresh endpoint takes a moment — without this, a
          // bug that fires one refresh per request (instead of queuing
          // them behind a single one) could still look correct in a
          // same-tick fake.
          return Future.delayed(
            const Duration(milliseconds: 20),
            () => _json(200, {
              'access_token': 'new-access',
              'refresh_token': 'new-refresh',
            }),
          );
        }
        final int callNumber = (callsByPath[options.path] ?? 0) + 1;
        callsByPath[options.path] = callNumber;
        if (callNumber == 1) {
          return _json(401, {'detail': 'expired'});
        }
        return _json(200, {
          'ok': true,
          'auth': options.headers['Authorization'],
        });
      }

      final Dio refreshDio = _dio(handler);
      final Dio dio = _dio(handler)
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: storage,
            onSessionExpired: onSessionExpired,
            refreshDio: refreshDio,
          ),
        );

      final List<Response<dynamic>> responses = await Future.wait([
        dio.get<dynamic>('/protected/a'),
        dio.get<dynamic>('/protected/b'),
        dio.get<dynamic>('/protected/c'),
      ]);

      expect(refreshCalls, 1);
      for (final Response<dynamic> response in responses) {
        expect(response.statusCode, 200);
        expect(
          (response.data as Map<String, dynamic>)['auth'],
          'Bearer new-access',
        );
      }
      expect(sessionExpiredCalls, 0);
    },
  );
}
