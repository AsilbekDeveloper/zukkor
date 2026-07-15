import '../entities/user.dart';

/// Auth backend bilan ishlash shartnomasi — amalga oshirilishi
/// `data/repositories/auth_repository_impl.dart`da bo'ladi.
abstract interface class AuthRepository {
  /// `POST /auth/register`. Muvaffaqiyatli bo'lsa tokenlar avtomatik
  /// saqlanadi — chaqiruvchi qo'shimcha ish qilmaydi, foydalanuvchi
  /// shu zahoti tizimga kirgan hisoblanadi.
  Future<void> register({
    required String email,
    required String username,
    required String password,
  });

  /// `POST /auth/login`. Muvaffaqiyatli bo'lsa tokenlar avtomatik saqlanadi.
  Future<void> login({
    required String email,
    required String password,
  });

  /// `GET /auth/me` — joriy tizimga kirgan foydalanuvchi ma'lumotlari.
  Future<User> getCurrentUser();

  /// `POST /auth/logout` — saqlangan refresh tokenni backendda bekor
  /// qiladi va lokal tokenlarni tozalaydi.
  Future<void> logout();
}
