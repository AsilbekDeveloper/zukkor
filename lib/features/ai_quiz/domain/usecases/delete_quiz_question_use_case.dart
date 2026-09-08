import '../repositories/ai_quiz_repository.dart';

class DeleteQuizQuestionUseCase {
  const DeleteQuizQuestionUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<void> call(int quizId, int questionId) =>
      _repository.deleteQuestion(quizId, questionId);
}
