import 'package:dio/dio.dart';

import '../constants/app_strings.dart';
import '../error/failures.dart';

/// [DioException] → [Failure] tarjimoni. Backend'ning umumiy xatolik
/// formatini (Zukkor_Umumiy_Arxitektura.docx, 5-bo'lim) parse qiladi:
///
/// ```json
/// { "error": "validation_error", "detail": { "email": ["..."] } }
/// { "error": "invalid_credentials", "detail": "Email yoki parol noto'g'ri." }
/// ```
abstract final class FailureMapper {
  static Failure fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure(AppStrings.errorTimeout),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => _fromResponse(e.response),
      _ => const UnknownFailure(),
    };
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final int status = response?.statusCode ?? 0;
    final dynamic data = response?.data;

    final String? detailMessage = _extractDetailMessage(data);

    return switch (status) {
      400 => ValidationFailure(
          detailMessage ?? AppStrings.errorUnknown,
          fieldErrors: _extractFieldErrors(data),
        ),
      401 => AuthFailure(detailMessage ?? AppStrings.errorInvalidCredentials),
      403 => AuthFailure(detailMessage ?? AppStrings.errorSessionExpired),
      404 => NotFoundFailure(detailMessage ?? AppStrings.errorUnknown),
      >= 500 => const ServerFailure(),
      _ => const UnknownFailure(),
    };
  }

  /// `detail` string bo'lsa — o'zi xabar; map bo'lsa — birinchi maydonning
  /// birinchi xabari (umumiy fallback sifatida).
  static String? _extractDetailMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is Map<String, dynamic>) {
      for (final dynamic messages in detail.values) {
        if (messages is List && messages.isNotEmpty) {
          return messages.first.toString();
        }
      }
    }
    return null;
  }

  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};
    final dynamic detail = data['detail'];
    if (detail is! Map<String, dynamic>) return const {};
    return detail.map(
      (String field, dynamic messages) => MapEntry(
        field,
        messages is List
            ? messages.map((dynamic m) => m.toString()).toList()
            : <String>[messages.toString()],
      ),
    );
  }
}
