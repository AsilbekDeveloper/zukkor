import '../constants/app_strings.dart';

/// Ilova bo'ylab yagona xatolik tili. Data qatlami qanday xato bo'lishidan
/// qat'i nazar (Dio, parsing, storage) — presentation qatlamiga faqat
/// [Failure] yetib boradi va UI `failure.message`ni ko'rsatadi, xolos.
///
/// Sealed bo'lgani uchun switch'da barcha holatlar qamrab olinishi
/// kompilyator tomonidan tekshiriladi.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Foydalanuvchiga ko'rsatishga tayyor (o'zbekcha) xabar.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Internet yo'q yoki server javob bermadi (timeout).
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.errorNoConnection]);
}

/// Server xatosi (5xx) yoki kutilmagan javob.
final class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.errorServer]);
}

/// Kirish ma'lumotlari noto'g'ri yoki sessiya tugagan (401).
final class AuthFailure extends Failure {
  const AuthFailure([super.message = AppStrings.errorInvalidCredentials]);
}

/// Backend validatsiya xatosi (400) — maydon-darajadagi xabarlar bilan.
/// Backend formati: {"error": "validation_error", "detail": {"email": ["..."]}}
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  /// Maydon nomi → xato xabarlari. Formalar buni tegishli input
  /// ostida ko'rsatish uchun ishlatadi.
  final Map<String, List<String>> fieldErrors;

  /// Berilgan maydonning birinchi xatosi (bo'lmasa null).
  String? forField(String field) {
    final List<String>? errors = fieldErrors[field];
    return (errors == null || errors.isEmpty) ? null : errors.first;
  }
}

/// So'ralgan resurs topilmadi (404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = AppStrings.errorUnknown]);
}

/// Tasniflab bo'lmagan xatolik.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.errorUnknown]);
}
