/// Backend'dagi ro'yxatdan o'tgan foydalanuvchi — `GET /auth/me` javobiga mos.
class User {
  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String username;
  final bool isActive;
  final DateTime createdAt;
}
