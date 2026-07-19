import '../../domain/entities/friend_request.dart';

class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.fromUserId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> fromUser = json['from_user'] as Map<String, dynamic>;
    return FriendRequestModel(
      id: json['id'] as String,
      fromUserId: fromUser['id'] as String,
      username: fromUser['username'] as String?,
      firstName: fromUser['first_name'] as String?,
      lastName: fromUser['last_name'] as String?,
      avatarColor: fromUser['avatar_color'] as String?,
      avatarImagePath: fromUser['avatar_image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String fromUserId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final DateTime createdAt;

  FriendRequest toEntity() => FriendRequest(
        id: id,
        fromUserId: fromUserId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        createdAt: createdAt.toLocal(),
      );
}
