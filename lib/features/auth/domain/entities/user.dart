/// Backend'dagi ro'yxatdan o'tgan foydalanuvchi — `GET /auth/me` javobiga mos.
/// `username`/`firstName`/`lastName`/`avatarColor`/`direction` faqat
/// Onboarding tugagach to'ldiriladi (`PATCH /users/me/profile`) — shu
/// sababli ular nullable.
class User {
  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
    required this.onboardingCompleted,
    required this.authProvider,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarColor,
    this.avatarImagePath,
    this.direction,
    this.interests,
    this.studyPlace,
    this.quizLiking,
  });

  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final bool onboardingCompleted;

  /// `"email"` or `"google"` — a Google account has no password at all
  /// (`hashed_password` is null server-side), so Change Password and the
  /// delete-account confirmation must both branch on this.
  final String authProvider;
  final String? username;
  final String? firstName;
  final String? lastName;
  // avatarColor va avatarImagePath bir-birini istisno qiladi — biri
  // o'rnatilsa, ikkinchisi backend tomonidan tozalanadi.
  final String? avatarColor;
  final String? avatarImagePath;
  final String? direction;

  /// Introduction so'rovnomasi javoblari — hammasi ixtiyoriy (foydalanuvchi
  /// so'rovnomani "Skip" qilgan bo'lishi mumkin). [studyPlace] bitta
  /// belgidan (`school`/`university`/`exam_prep`/`other`) yoki erkin
  /// matndan (foydalanuvchi "Boshqa" tanlab, o'zicha yozgan javob) iborat
  /// bo'lishi mumkin — ko'rsatishdan oldin taniqli belgini tarjima qilib,
  /// aks holda xomligicha ko'rsatish kerak.
  final List<String>? interests;
  final String? studyPlace;
  final String? quizLiking;

  bool get isGoogleAccount => authProvider == 'google';
}

/// Foydalanuvchini ekranda ko'rsatish uchun hosilaviy qiymatlar — Home va
/// Profile ekranlari o'rtasida umumiy (ilgari ikkala joyda takrorlangan edi).
/// `User?` ustida — foydalanuvchi hali yuklanmagan (`null`) holat ham
/// xavfsiz boshqariladi.
extension UserDisplayX on User? {
  /// Ism va familiya bosh harflari (masalan "AK"). Ikkalasi ham bo'sh
  /// bo'lsa "?" qaytadi.
  String get initials {
    final String first = (this?.firstName?.isNotEmpty ?? false) ? this!.firstName![0] : '';
    final String last = (this?.lastName?.isNotEmpty ?? false) ? this!.lastName![0] : '';
    final String combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }

  /// To'liq ism ("Ism Familiya"); bo'sh bo'lsa username; u ham bo'lmasa
  /// bo'sh satr.
  String get displayName {
    final String name = [this?.firstName, this?.lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');
    return name.isNotEmpty ? name : (this?.username ?? '');
  }
}
