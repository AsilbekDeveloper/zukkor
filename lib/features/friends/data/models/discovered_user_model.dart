import '../../domain/entities/discovered_user.dart';

class DiscoveredUserModel {
  const DiscoveredUserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.requestPending,
  });

  factory DiscoveredUserModel.fromJson(Map<String, dynamic> json) => DiscoveredUserModel(
        id: json['id'] as String,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        requestPending: json['request_pending'] as bool,
      );

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final bool requestPending;

  DiscoveredUser toEntity() => DiscoveredUser(
        id: id,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        requestPending: requestPending,
      );
}
