import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class GenerateAiQuizUseCase {
  const GenerateAiQuizUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<AiQuiz> call({
    required String filePath,
    required String fileName,
    required String instruction,
    required int questionCount,
  }) =>
      _repository.generate(
        filePath: filePath,
        fileName: fileName,
        instruction: instruction,
        questionCount: questionCount,
      );
}
