import '../entities/ai_quiz.dart';
import '../entities/manual_question_input.dart';
import '../repositories/ai_quiz_repository.dart';

class CreateManualQuizUseCase {
  const CreateManualQuizUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<AiQuiz> call({
    required String name,
    required List<ManualQuestionInput> questions,
    int? topicCategoryId,
  }) =>
      _repository.createManual(name: name, questions: questions, topicCategoryId: topicCategoryId);
}
