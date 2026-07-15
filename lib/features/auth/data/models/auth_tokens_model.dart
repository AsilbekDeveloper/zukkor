import '../../domain/entities/auth_tokens.dart';

/// `/auth/register`, `/auth/login`, `/auth/refresh` javobining xom shakli:
/// `{ "access_token": "...", "refresh_token": "...", "token_type": "bearer" }`
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  final String accessToken;
  final String refreshToken;

  AuthTokens toEntity() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}
