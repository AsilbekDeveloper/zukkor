import '../entities/manual_question_input.dart';
import '../entities/quiz_question.dart';
import '../repositories/ai_quiz_repository.dart';

class UpdateQuizQuestionUseCase {
  const UpdateQuizQuestionUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<QuizQuestion> call(
    int quizId,
    int questionId,
    ManualQuestionInput question,
  ) => _repository.updateQuestion(quizId, questionId, question);
}
