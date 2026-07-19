import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Tanlangan rasmni avatar sifatida yuklash.
class UploadAvatarImageUseCase {
  const UploadAvatarImageUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call(String filePath) => _repository.uploadAvatarImage(filePath);
}
