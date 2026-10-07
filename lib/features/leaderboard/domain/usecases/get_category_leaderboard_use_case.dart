import '../entities/category_leaderboard_data.dart';
import '../entities/leaderboard_scope.dart';
import '../repositories/leaderboard_repository.dart';

class GetCategoryLeaderboardUseCase {
  const GetCategoryLeaderboardUseCase(this._repository);

  final LeaderboardRepository _repository;

  Future<CategoryLeaderboardData> call({
    required int categoryId,
    int limit = 20,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) =>
      _repository.getCategoryLeaderboard(categoryId: categoryId, limit: limit, scope: scope, offset: offset);
}
