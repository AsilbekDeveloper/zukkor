import '../../domain/entities/friend.dart';

class FriendModel {
  const FriendModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
        id: json['id'] as String,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
      );

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;

  Friend toEntity() => Friend(
        id: id,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
      );
}
