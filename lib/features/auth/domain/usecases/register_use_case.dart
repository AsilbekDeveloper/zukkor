import '../repositories/auth_repository.dart';

/// Email + username + parol bilan ro'yxatdan o'tish.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String username,
    required String password,
  }) =>
      _repository.register(email: email, username: username, password: password);
}
