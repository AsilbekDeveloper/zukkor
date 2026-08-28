/// `GET /leaderboard/{user_id}`'s response — one player's full public
/// profile stats, shown on [PlayerDetailScreen].
class PlayerStats {
  const PlayerStats({
    required this.userId,
    required this.rank,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.gamesPlayed,
    required this.winRatePercent,
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
  final int currentStreak;
  final int longestStreak;
  final int gamesPlayed;
  final int winRatePercent;
}
