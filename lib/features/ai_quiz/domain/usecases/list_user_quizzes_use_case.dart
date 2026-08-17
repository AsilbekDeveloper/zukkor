import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class ListUserQuizzesUseCase {
  const ListUserQuizzesUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<List<AiQuiz>> call(String userId) => _repository.listForUser(userId);
}
