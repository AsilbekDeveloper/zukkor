import '../entities/leaderboard_data.dart';
import '../entities/leaderboard_scope.dart';
import '../entities/player_stats.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardData> getLeaderboard({int limit = 50, LeaderboardScope scope = LeaderboardScope.allTime});

  Future<PlayerStats> getPlayerStats(String userId);
}
