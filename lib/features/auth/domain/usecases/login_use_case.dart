import '../repositories/auth_repository.dart';

/// Email + parol bilan tizimga kirish.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
