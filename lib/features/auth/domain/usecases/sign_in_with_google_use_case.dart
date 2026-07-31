import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Google bilan kirish/ro'yxatdan o'tish.
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.signInWithGoogle();
}
