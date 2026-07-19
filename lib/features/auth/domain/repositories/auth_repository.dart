import '../entities/user.dart';

/// Auth backend bilan ishlash shartnomasi — amalga oshirilishi
/// `data/repositories/auth_repository_impl.dart`da bo'ladi.
abstract interface class AuthRepository {
  /// `POST /auth/register`. Muvaffaqiyatli bo'lsa tokenlar avtomatik
  /// saqlanadi — chaqiruvchi qo'shimcha ish qilmaydi, foydalanuvchi
  /// shu zahoti tizimga kirgan hisoblanadi. `username` bu bosqichda
  /// so'ralmaydi — u Onboarding'da ([updateProfile]) beriladi.
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

  /// `PATCH /users/me/profile` — profil ma'lumotlarini (avatar,
  /// ism/familiya/username, yo'nalish) saqlaydi. Onboarding wizard'ini
  /// yakunlash uchun ham, keyinroq Profilni tahrirlash uchun ham
  /// ishlatiladi — ikkalasi ham barcha 5 maydonni birga yuborishi kerak.
  ///
  /// [interests]/[studyPlace]/[quizLiking] — faqat Onboarding'ni
  /// Introduction so'rovnomasidan keyin yakunlaganda beriladi (Profilni
  /// tahrirlashda `null` — mavjud qiymatlar backend'da o'zgarishsiz qoladi).
  Future<User> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  });

  /// `POST /users/me/avatar` — tanlangan rasmni yuklaydi va uni joriy
  /// avatar sifatida saqlaydi (backend `avatar_color`ni tozalaydi —
  /// bir-birini istisno qiladi). Yangilangan foydalanuvchini qaytaradi.
  Future<User> uploadAvatarImage(String filePath);

  /// `POST /auth/change-password` — joriy parolni tekshirib, yangi
  /// parolga almashtiradi.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// `DELETE /auth/me` — hisobni butunlay o'chiradi (parol bilan
  /// tasdiqlangandan so'ng). Muvaffaqiyatli bo'lsa lokal tokenlar ham
  /// tozalanadi — chaqiruvchi faqat Login ekraniga yo'naltirishi kerak.
  Future<void> deleteAccount(String password);

  /// `GET /users/username-available` — hech narsa saqlamasdan username
  /// bandligini tekshiradi (Onboarding 2-bosqichida va Profilni
  /// tahrirlashda username o'zgartirilganda ishlatiladi).
  Future<bool> isUsernameAvailable(String username);

  /// `POST /auth/logout` — saqlangan refresh tokenni backendda bekor
  /// qiladi va lokal tokenlarni tozalaydi.
  Future<void> logout();
}
