import '../repositories/ai_quiz_repository.dart';

class DeleteAiQuizUseCase {
  const DeleteAiQuizUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
