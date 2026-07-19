import '../entities/player_stats.dart';
import '../repositories/leaderboard_repository.dart';

class GetPlayerStatsUseCase {
  const GetPlayerStatsUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<PlayerStats> call(String userId) => _repository.getPlayerStats(userId);
}
