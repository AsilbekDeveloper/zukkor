import '../constants/app_strings.dart';

/// Forma validatorlari — SOF funksiyalar (holatga bog'liq emas, to'liq
/// testlanadi). Qoidalar backend hujjatlaridagi bilan AYNAN bir xil,
/// shunda client o'tkazgan qiymatni server ham o'tkazadi:
///
///  - parol: kamida 8 belgi                (Zukkor_Login.docx, 2-bo'lim)
///  - username: ^[a-zA-Z0-9_]{3,30}$       (Zukkor_Profil_Yaratish.docx)
///  - ism/familiya: 1-50 belgi             (Zukkor_Profil_Yaratish.docx)
///
/// Qaytarilgan qiymat: xato matni yoki null (valid).
abstract final class Validators {
  static final RegExp _emailRegex =
      RegExp(r'^[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');

  static String? email(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.emailRequired;
    if (!_emailRegex.hasMatch(v)) return AppStrings.emailInvalid;
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return AppStrings.passwordRequired;
    if (v.length < 8) return AppStrings.passwordTooShort;
    return null;
  }

  /// [original] — asosiy parol maydonining joriy qiymati. Register
  /// ekranida ishlatiladi: foydalanuvchi ikkinchi marta kiritgan parol
  /// birinchisi bilan mos kelishini tekshiradi.
  static String? confirmPassword(String? value, String original) {
    final String v = value ?? '';
    if (v.isEmpty) return AppStrings.passwordRequired;
    if (v != original) return AppStrings.passwordMismatch;
    return null;
  }

  static String? username(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.usernameRequired;
    if (!_usernameRegex.hasMatch(v)) return AppStrings.usernameInvalid;
    return null;
  }

  static String? personName(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.nameRequired;
    if (v.length > 50) return AppStrings.nameTooLong;
    return null;
  }
}
