import '../entities/ai_quiz.dart';
import '../repositories/ai_quiz_repository.dart';

class UpdateQuizTopicUseCase {
  const UpdateQuizTopicUseCase(this._repository);

  final AiQuizRepository _repository;

  Future<AiQuiz> call(int id, int? topicCategoryId) => _repository.updateTopic(id, topicCategoryId);
}
