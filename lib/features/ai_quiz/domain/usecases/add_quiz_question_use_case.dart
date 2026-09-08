import '../entities/manual_question_input.dart';
import '../entities/quiz_question.dart';
import '../repositories/ai_quiz_repository.dart';

class AddQuizQuestionUseCase {
  const AddQuizQuestionUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<QuizQuestion> call(int quizId, ManualQuestionInput question) =>
      _repository.addQuestion(quizId, question);
}
