import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class ListAiQuizzesUseCase {
  const ListAiQuizzesUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<List<AiQuiz>> call() => _repository.list();
}
