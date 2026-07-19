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
    this.username,
    this.firstName,
    this.lastName,
    this.avatarColor,
    this.avatarImagePath,
    this.direction,
  });

  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final bool onboardingCompleted;
  final String? username;
  final String? firstName;
  final String? lastName;
  // avatarColor va avatarImagePath bir-birini istisno qiladi — biri
  // o'rnatilsa, ikkinchisi backend tomonidan tozalanadi.
  final String? avatarColor;
  final String? avatarImagePath;
  final String? direction;
}
