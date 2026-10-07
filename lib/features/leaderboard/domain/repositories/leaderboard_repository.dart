import '../entities/category_leaderboard_data.dart';
import '../entities/leaderboard_data.dart';
import '../entities/leaderboard_scope.dart';
import '../entities/player_stats.dart';

abstract interface class LeaderboardRepository {
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  });

  Future<PlayerStats> getPlayerStats(String userId);

  Future<CategoryLeaderboardData> getCategoryLeaderboard({
    required int categoryId,
    int limit = 20,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  });
}
