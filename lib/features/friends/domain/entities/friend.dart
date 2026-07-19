/// A mutual friend — `GET /friends` response entry.
class Friend {
  const Friend({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
  });

  final String id;
  // Null when a user earned this friendship before ever completing
  // onboarding (same as Leaderboard/History's username).
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
}
