import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Profil ma'lumotlarini saqlash — Onboarding wizard'ini yakunlash uchun
/// ham, Profilni tahrirlash uchun ham ishlatiladi.
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  }) =>
      _repository.updateProfile(
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        direction: direction,
        interests: interests,
        studyPlace: studyPlace,
        quizLiking: quizLiking,
      );
}
