import 'package:dio/dio.dart';

import '../../i18n/strings.g.dart';
import '../error/failures.dart';

/// [DioException] → [Failure] tarjimoni. Backend'ning xatolik formatini
/// parse qiladi (ikki ko'rinishi bor):
///
/// ```json
/// { "detail": "Email yoki parol noto'g'ri" }
/// { "detail": [{ "type": "value_error", "loc": ["body", "password"], "msg": "..." }] }
/// ```
abstract final class FailureMapper {
  static Failure fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        NetworkFailure(t.errors.timeout),
      DioExceptionType.connectionError => NetworkFailure(),
      DioExceptionType.badResponse => _fromResponse(e.response),
      _ => UnknownFailure(),
    };
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final int status = response?.statusCode ?? 0;
    final dynamic data = response?.data;

    final String? detailMessage = _extractDetailMessage(data);

    return switch (status) {
      400 => ValidationFailure(detailMessage ?? t.errors.unknown),
      401 => AuthFailure(detailMessage ?? t.errors.invalidCredentials),
      403 => AuthFailure(detailMessage ?? t.errors.sessionExpired),
      404 => NotFoundFailure(detailMessage ?? t.errors.unknown),
      422 => ValidationFailure(
          detailMessage ?? t.errors.unknown,
          fieldErrors: _extractFieldErrors(data),
        ),
      >= 500 => ServerFailure(),
      _ => UnknownFailure(),
    };
  }

  /// `detail` oddiy matn bo'lsa — o'zi xabar; ro'yxat (422 validatsiya
  /// formati) bo'lsa — birinchi elementning `msg`i.
  static String? _extractDetailMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final dynamic detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      final dynamic first = detail.first;
      if (first is Map<String, dynamic>) {
        final dynamic msg = first['msg'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    }
    return null;
  }

  /// 422 validatsiya ro'yxatini maydon nomi → xabarlar map'iga aylantiradi.
  /// Har elementning `loc`i masalan `["body", "password"]` — oxirgi element
  /// maydon nomi.
  static Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};
    final dynamic detail = data['detail'];
    if (detail is! List) return const {};

    final Map<String, List<String>> fieldErrors = {};
    for (final dynamic item in detail) {
      if (item is! Map<String, dynamic>) continue;
      final dynamic loc = item['loc'];
      final dynamic msg = item['msg'];
      if (loc is! List || loc.isEmpty || msg is! String) continue;
      final String field = loc.last.toString();
      (fieldErrors[field] ??= []).add(msg);
    }
    return fieldErrors;
  }
}
