import '../entities/discover_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class DiscoverQuizzesUseCase {
  const DiscoverQuizzesUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<List<DiscoverQuiz>> call() => _repository.discover();
}
