import '../entities/answer_result.dart';
import '../repositories/quiz_repository.dart';

class SubmitAnswerUseCase {
  const SubmitAnswerUseCase(this._repository);

  final QuizRepository _repository;

  Future<AnswerResult> call({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      _repository.submitAnswer(
        sessionId: sessionId,
        sessionQuestionId: sessionQuestionId,
        selectedOption: selectedOption,
      );
}
