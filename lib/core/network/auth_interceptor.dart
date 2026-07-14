import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

/// JWT interceptor:
///
///  1. Har bir so'rovga `Authorization: Bearer <access>` qo'shadi
///     (auth endpoint'laridan tashqari — ularga token kerak emas).
///  2. 401 kelganda refresh token bilan yangi access oladi va asl so'rovni
///     qaytadan yuboradi.
///  3. Refresh ham muvaffaqiyatsiz bo'lsa — tokenlarni tozalab,
///     [onSessionExpired] chaqiradi (auth qatlami logout qiladi).
///
/// [QueuedInterceptor]dan meros olingan — Dio bir vaqtda faqat bitta
/// error-handler ishlashini kafolatlaydi: 10 ta parallel so'rov birdan
/// 401 olsa ham, refresh FAQAT BIR MARTA yuboriladi, qolganlari navbatda
/// kutib, yangilangan token bilan davom etadi.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required void Function() onSessionExpired,
    Dio? refreshDio,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired,
        // Refresh so'rovi uchun ALOHIDA, interceptor'siz Dio —
        // aks holda refresh'ning o'zi 401 olsa cheksiz tsikl bo'lardi.
        _refreshDio = refreshDio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
            ));

  final TokenStorage _tokenStorage;
  final void Function() _onSessionExpired;
  final Dio _refreshDio;

  /// Token talab qilmaydigan yo'llar.
  static const Set<String> _publicPaths = {
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.google,
    ApiEndpoints.tokenRefresh,
    ApiEndpoints.categories,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicPaths.contains(options.path)) {
      final String? access = await _tokenStorage.readAccessToken();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final bool isUnauthorized = err.response?.statusCode == 401;
    final bool isAuthRequest = _publicPaths.contains(err.requestOptions.path);

    if (!isUnauthorized || isAuthRequest) {
      handler.next(err);
      return;
    }

    final String? refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null) {
      _expire();
      handler.next(err);
      return;
    }

    try {
      final Response<dynamic> response = await _refreshDio.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refresh},
      );
      final String newAccess = response.data['access'] as String;
      // ROTATE_REFRESH_TOKENS: backend yangi refresh ham qaytarishi mumkin.
      final String? newRefresh = response.data['refresh'] as String?;
      await _tokenStorage.saveTokens(access: newAccess, refresh: newRefresh);

      // Asl so'rovni yangi token bilan takrorlaymiz.
      final RequestOptions original = err.requestOptions;
      original.headers['Authorization'] = 'Bearer $newAccess';
      final Response<dynamic> retried = await _refreshDio.fetch(original);
      handler.resolve(retried);
    } on DioException catch (retryError) {
      _expire();
      handler.next(retryError);
    }
  }

  void _expire() {
    // Kutmasdan (fire-and-forget) tozalaymiz — foydalanuvchini chiqarish
    // signal darhol ketishi muhimroq.
    _tokenStorage.clear();
    _onSessionExpired();
  }
}
