import '../entities/quiz_start_result.dart';
import '../repositories/quiz_repository.dart';

class StartQuizUseCase {
  const StartQuizUseCase(this._repository);

  final QuizRepository _repository;

  Future<QuizStartResult> call({required int categoryId, required int questionCount}) =>
      _repository.startQuiz(categoryId: categoryId, questionCount: questionCount);
}
