import '../../domain/entities/player_stats.dart';

class PlayerStatsModel {
  const PlayerStatsModel({
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
    required this.totalWins,
    required this.bestRankAchieved,
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) => PlayerStatsModel(
        userId: json['user_id'] as String,
        rank: json['rank'] as int,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        totalXp: json['total_xp'] as int,
        currentStreak: json['current_streak'] as int,
        longestStreak: json['longest_streak'] as int,
        gamesPlayed: json['games_played'] as int,
        winRatePercent: json['win_rate_percent'] as int,
        totalWins: json['total_wins'] as int,
        bestRankAchieved: json['best_rank_achieved'] as int,
      );

  final String userId;
  final int rank;
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
  final int totalWins;
  final int bestRankAchieved;

  PlayerStats toEntity() => PlayerStats(
        userId: userId,
        rank: rank,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        totalXp: totalXp,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        gamesPlayed: gamesPlayed,
        winRatePercent: winRatePercent,
        totalWins: totalWins,
        bestRankAchieved: bestRankAchieved,
      );
}
