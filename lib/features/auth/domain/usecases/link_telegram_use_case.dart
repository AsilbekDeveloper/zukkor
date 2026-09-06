import '../repositories/auth_repository.dart';

/// Bot bergan 6 xonali kodni tasdiqlab, joriy hisobni Telegram akkauntiga
/// bog'lash.
class LinkTelegramUseCase {
  const LinkTelegramUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String code) => _repository.linkTelegram(code);
}
