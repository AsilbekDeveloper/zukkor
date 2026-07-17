import '../entities/user.dart';

/// Auth backend bilan ishlash shartnomasi — amalga oshirilishi
/// `data/repositories/auth_repository_impl.dart`da bo'ladi.
abstract interface class AuthRepository {
  /// `POST /auth/register`. Muvaffaqiyatli bo'lsa tokenlar avtomatik
  /// saqlanadi — chaqiruvchi qo'shimcha ish qilmaydi, foydalanuvchi
  /// shu zahoti tizimga kirgan hisoblanadi. `username` bu bosqichda
  /// so'ralmaydi — u Onboarding'da ([completeOnboarding]) beriladi.
  Future<void> register({
    required String email,
    required String password,
  });

  /// `POST /auth/login`. Muvaffaqiyatli bo'lsa tokenlar avtomatik saqlanadi.
  Future<void> login({
    required String email,
    required String password,
  });

  /// `GET /auth/me` — joriy tizimga kirgan foydalanuvchi ma'lumotlari.
  Future<User> getCurrentUser();

  /// `PATCH /users/me/profile` — Onboarding wizard'ining 3 bosqichini
  /// (avatar, ism/familiya/username, yo'nalish) bitta so'rovda yakunlaydi.
  Future<User> completeOnboarding({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
  });

  /// `GET /users/username-available` — hech narsa saqlamasdan username
  /// bandligini tekshiradi (Onboarding 2-bosqichida "Continue" bosilganda).
  Future<bool> isUsernameAvailable(String username);

  /// `POST /auth/logout` — saqlangan refresh tokenni backendda bekor
  /// qiladi va lokal tokenlarni tozalaydi.
  Future<void> logout();
}
