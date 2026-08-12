import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class GenerateAiQuizUseCase {
  const GenerateAiQuizUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<AiQuiz> call({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
  }) =>
      _repository.generate(
        filePath: filePath,
        fileName: fileName,
        instruction: instruction,
        topic: topic,
        questionCount: questionCount,
      );
}
