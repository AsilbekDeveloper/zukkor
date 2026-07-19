import '../entities/leaderboard_data.dart';
import '../entities/leaderboard_scope.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboardUseCase {
  const GetLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<LeaderboardData> call({int limit = 50, LeaderboardScope scope = LeaderboardScope.allTime}) =>
      _repository.getLeaderboard(limit: limit, scope: scope);
}
