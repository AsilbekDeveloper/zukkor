import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Joriy tizimga kirgan foydalanuvchi ma'lumotlarini olish.
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call() => _repository.getCurrentUser();
}
