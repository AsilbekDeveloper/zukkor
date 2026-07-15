import '../repositories/auth_repository.dart';

/// Tizimdan chiqish — refresh tokenni backendda bekor qiladi va lokal
/// tokenlarni tozalaydi.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
