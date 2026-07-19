import '../repositories/auth_repository.dart';

/// Hisobni parol bilan tasdiqlangandan so'ng butunlay o'chirish.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String password) => _repository.deleteAccount(password);
}
