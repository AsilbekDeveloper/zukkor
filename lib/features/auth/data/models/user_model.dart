import '../../domain/entities/user.dart';

/// `GET /auth/me` va `PATCH /users/me/profile` javobining xom shakli:
/// `{ "id", "email", "username", "is_active", "created_at", "first_name",
///    "last_name", "avatar_color", "direction", "onboarding_completed" }`
class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        onboardingCompleted: json['onboarding_completed'] as bool,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        direction: json['direction'] as String?,
      );

  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final bool onboardingCompleted;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final String? direction;

  User toEntity() => User(
        id: id,
        email: email,
        isActive: isActive,
        createdAt: createdAt,
        onboardingCompleted: onboardingCompleted,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        direction: direction,
      );
}
