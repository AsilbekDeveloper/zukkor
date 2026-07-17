import '../repositories/auth_repository.dart';

/// Username bandligini hech narsa saqlamasdan tekshirish.
class CheckUsernameAvailableUseCase {
  const CheckUsernameAvailableUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call(String username) => _repository.isUsernameAvailable(username);
}
