import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Onboarding wizard'ini yakunlash — avatar rang, ism/familiya/username,
/// yo'nalishni bitta so'rovda backendga yuboradi.
class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
  }) =>
      _repository.completeOnboarding(
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        direction: direction,
      );
}
