import '../entities/discover_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class SearchDiscoverQuizzesUseCase {
  const SearchDiscoverQuizzesUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<List<DiscoverQuiz>> call(String query, {int? categoryId}) =>
      _repository.searchDiscover(query, categoryId: categoryId);
}
