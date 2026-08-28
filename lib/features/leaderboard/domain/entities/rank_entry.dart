/// One row of the `/leaderboard` response — a user's public rank, name
/// and XP. `isMe` is set server-side so the client never has to compare
/// user ids itself.
class RankEntry {
  const RankEntry({
    required this.userId,
    required this.rank,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.totalXp,
    required this.isMe,
  });

  final String userId;
  final int rank;

  /// Null for a user who earned XP before ever completing onboarding
  /// (no username set yet).
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final int totalXp;
  final bool isMe;
}
