import '../repositories/auth_repository.dart';

/// Ushbu qurilmaning FCM push-token'ini joriy foydalanuvchiga bog'laydi.
class RegisterPushTokenUseCase {
  const RegisterPushTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String token) => _repository.registerPushToken(token);
}
