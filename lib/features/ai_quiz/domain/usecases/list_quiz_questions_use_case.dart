import '../entities/quiz_question.dart';
import '../repositories/ai_quiz_repository.dart';

class ListQuizQuestionsUseCase {
  const ListQuizQuestionsUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<List<QuizQuestion>> call(int quizId) =>
      _repository.listQuestions(quizId);
}
