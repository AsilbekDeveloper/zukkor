/// An incoming friend request — `GET /friends/requests/incoming` entry.
class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.createdAt,
  });

  final String id;
  final String fromUserId;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final DateTime createdAt;
}
