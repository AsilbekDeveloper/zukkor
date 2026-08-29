import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zukkor/features/auth/data/datasources/google_auth_data_source.dart';
import 'package:zukkor/features/auth/data/models/auth_tokens_model.dart';
import 'package:zukkor/features/auth/data/models/user_model.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeAuthRemoteDataSource extends Fake implements AuthRemoteDataSource {
  AuthTokensModel? nextTokens;
  UserModel? nextUser;
  Object? nextError;
  String? lastAccessToken;
  VoidCallback? loginCallback;

  @override
  Future<AuthTokensModel> login({required String email, required String password}) async {
    loginCallback?.call();
    if (nextError != null && nextTokens == null) throw nextError!;
    return nextTokens!;
  }

  @override
  Future<UserModel> getCurrentUserForToken(String accessToken) async {
    lastAccessToken = accessToken;
    if (nextError != null) throw nextError!;
    return nextUser!;
  }
}

class _FakeTokenStorage extends Fake implements TokenStorage {
  final List<String> calls = [];
  String? pendingAccess;
  String? registeredUserId;

  @override
  Future<void> savePendingLoginTokens({required String access, String? refresh}) async {
    calls.add('savePendingLoginTokens');
    pendingAccess = access;
  }

  @override
  Future<void> registerActiveSession({required String userId, required StoredAccountInfo info}) async {
    calls.add('registerActiveSession');
    registeredUserId = userId;
  }
}

void main() {
  late _FakeAuthRemoteDataSource remote;
  late _FakeTokenStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeAuthRemoteDataSource();
    storage = _FakeTokenStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      googleAuthDataSource: FakeGoogleAuthDataSource(),
      tokenStorage: storage,
    );
  });

  const tokens = AuthTokensModel(accessToken: 'at', refreshToken: 'rt');
  final user = UserModel(
    id: 'u1',
    email: 'u@t.co',
    isActive: true,
    createdAt: DateTime(2026),
    onboardingCompleted: true,
    authProvider: 'email',
  );

  test('addAccount success: follows 4-step sequence', () async {
    remote.nextTokens = tokens;
    remote.nextUser = user;

    final result = await repository.addAccount(email: 'e', password: 'p');

    expect(result.id, 'u1');
    expect(remote.lastAccessToken, 'at');
    expect(storage.calls, ['savePendingLoginTokens', 'registerActiveSession']);
    expect(storage.pendingAccess, 'at');
    expect(storage.registeredUserId, 'u1');
  });

  test('addAccount: login failure does not write to storage', () async {
    remote.nextError = DioException(requestOptions: RequestOptions());

    expect(() => repository.addAccount(email: 'e', password: 'p'), throwsA(isA<Exception>()));
    expect(storage.calls, isEmpty);
  });

  test('addAccount: getCurrentUserForToken failure does not write to storage', () async {
    remote.nextTokens = tokens;
    // login succeeds, but identity fetch fails
    bool loginCalled = false;
    remote.loginCallback = () => loginCalled = true;
    remote.nextError = DioException(requestOptions: RequestOptions());

    expect(() => repository.addAccount(email: 'e', password: 'p'), throwsA(isA<Exception>()));
    expect(loginCalled, isTrue);
    expect(storage.calls, isEmpty);
  });
}

class FakeGoogleAuthDataSource extends Fake implements GoogleAuthDataSource {}
