import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _repository.resetPassword(email: email, code: code, newPassword: newPassword);
}
