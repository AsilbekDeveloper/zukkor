import '../../i18n/strings.g.dart';

/// Forma validatorlari — SOF funksiyalar (holatga bog'liq emas, to'liq
/// testlanadi). Qoidalar backend bilan AYNAN bir xil, shunda client
/// o'tkazgan qiymatni server ham o'tkazadi:
///
///  - parol: kamida 8 belgi + 1 katta harf + 1 raqam (auth backend, 2026-07-15)
///  - username: ^[a-zA-Z0-9_]{3,30}$       (Zukkor_Profil_Yaratish.docx)
///  - ism/familiya: 1-50 belgi             (Zukkor_Profil_Yaratish.docx)
///
/// Qaytarilgan qiymat: xato matni yoki null (valid). Bu funksiyalar
/// [BuildContext] qabul qilmaydi (TextFormField.validator sifatida
/// ishlatiladi), shu sababli reaktiv `context.t` emas, global `t`
/// ishlatiladi — har chaqiruvda joriy tilni to'g'ri o'qiydi.
abstract final class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  static String? email(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return t.authValidation.emailRequired;
    if (!_emailRegex.hasMatch(v)) return t.authValidation.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return t.authValidation.passwordRequired;
    if (v.length < 8 ||
        !_uppercaseRegex.hasMatch(v) ||
        !_digitRegex.hasMatch(v)) {
      return t.authValidation.passwordTooShort;
    }
    return null;
  }

  /// [original] — asosiy parol maydonining joriy qiymati. Register
  /// ekranida ishlatiladi: foydalanuvchi ikkinchi marta kiritgan parol
  /// birinchisi bilan mos kelishini tekshiradi.
  static String? confirmPassword(String? value, String original) {
    final String v = value ?? '';
    if (v.isEmpty) return t.authValidation.passwordRequired;
    if (v != original) return t.authValidation.passwordMismatch;
    return null;
  }

  static String? username(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return t.authValidation.usernameRequired;
    if (!_usernameRegex.hasMatch(v)) return t.authValidation.usernameInvalid;
    return null;
  }

  static String? personName(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return t.authValidation.nameRequired;
    if (v.length > 50) return t.authValidation.nameTooLong;
    return null;
  }
}
