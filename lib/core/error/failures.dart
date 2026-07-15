import '../../i18n/strings.g.dart';

/// Ilova bo'ylab yagona xatolik tili. Data qatlami qanday xato bo'lishidan
/// qat'i nazar (Dio, parsing, storage) — presentation qatlamiga faqat
/// [Failure] yetib boradi va UI `failure.message`ni ko'rsatadi, xolos.
///
/// Sealed bo'lgani uchun switch'da barcha holatlar qamrab olinishi
/// kompilyator tomonidan tekshiriladi.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Foydalanuvchiga ko'rsatishga tayyor xabar.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Internet yo'q yoki server javob bermadi (timeout).
///
/// Default xabar `context.t` emas global `t`dan olinadi — konstruktor
/// `const` bo'la olmaydi, chunki tarjima joriy tilga qarab o'zgaradi.
final class NetworkFailure extends Failure {
  NetworkFailure([String? message]) : super(message ?? t.errors.noConnection);
}

/// Server xatosi (5xx) yoki kutilmagan javob.
final class ServerFailure extends Failure {
  ServerFailure([String? message]) : super(message ?? t.errors.server);
}

/// Kirish ma'lumotlari noto'g'ri yoki sessiya tugagan (401).
final class AuthFailure extends Failure {
  AuthFailure([String? message]) : super(message ?? t.errors.invalidCredentials);
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
  NotFoundFailure([String? message]) : super(message ?? t.errors.unknown);
}

/// Tasniflab bo'lmagan xatolik.
final class UnknownFailure extends Failure {
  UnknownFailure([String? message]) : super(message ?? t.errors.unknown);
}
