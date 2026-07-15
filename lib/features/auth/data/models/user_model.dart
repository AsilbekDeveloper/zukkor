import '../../domain/entities/user.dart';

/// `GET /auth/me` javobining xom shakli:
/// `{ "id", "email", "username", "is_active", "created_at" }`
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final String id;
  final String email;
  final String username;
  final bool isActive;
  final DateTime createdAt;

  User toEntity() => User(
        id: id,
        email: email,
        username: username,
        isActive: isActive,
        createdAt: createdAt,
      );
}
