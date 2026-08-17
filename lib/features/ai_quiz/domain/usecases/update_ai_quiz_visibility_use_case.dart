import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class UpdateAiQuizVisibilityUseCase {
  const UpdateAiQuizVisibilityUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<AiQuiz> call(int id, String visibility) => _repository.updateVisibility(id, visibility);
}
