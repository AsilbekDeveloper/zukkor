import '../repositories/auth_repository.dart';

/// Joriy parolni tekshirib, yangi parolga almashtirish.
class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String currentPassword, required String newPassword}) =>
      _repository.changePassword(currentPassword: currentPassword, newPassword: newPassword);
}
