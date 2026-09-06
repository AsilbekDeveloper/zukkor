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
    this.coinBalance = 0,
    this.diamondBalance = 0,
    this.referralCode,
    this.telegramLinked = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        onboardingCompleted: json['onboarding_completed'] as bool,
        authProvider: json['auth_provider'] as String,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        direction: json['direction'] as String?,
        interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
        studyPlace: json['study_place'] as String?,
        quizLiking: json['quiz_liking'] as String?,
        coinBalance: json['coin_balance'] as int? ?? 0,
        diamondBalance: json['diamond_balance'] as int? ?? 0,
        referralCode: json['referral_code'] as String?,
        telegramLinked: json['telegram_linked'] as bool? ?? false,
      );

  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final bool onboardingCompleted;
  final String authProvider;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final String? direction;
  final List<String>? interests;
  final String? studyPlace;
  final String? quizLiking;
  final int coinBalance;
  final int diamondBalance;
  final String? referralCode;
  final bool telegramLinked;

  User toEntity() => User(
        id: id,
        email: email,
        isActive: isActive,
        createdAt: createdAt,
        onboardingCompleted: onboardingCompleted,
        authProvider: authProvider,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        direction: direction,
        interests: interests,
        studyPlace: studyPlace,
        quizLiking: quizLiking,
        coinBalance: coinBalance,
        diamondBalance: diamondBalance,
        referralCode: referralCode,
        telegramLinked: telegramLinked,
      );
}
