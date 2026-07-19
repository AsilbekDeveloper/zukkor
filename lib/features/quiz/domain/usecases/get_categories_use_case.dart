import '../entities/category.dart';
import '../repositories/quiz_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final QuizRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
