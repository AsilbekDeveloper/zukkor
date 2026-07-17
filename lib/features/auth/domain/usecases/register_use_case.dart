import '../repositories/auth_repository.dart';

/// Email + parol bilan ro'yxatdan o'tish.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.register(email: email, password: password);
}
