import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../user_session.dart';

/// Login/Register/Logout/Profil-yangilash amallarini boshqaradi. Holati —
/// shunchaki `isLoading` bayrog'i (ekranlarda spinner ko'rsatish uchun);
/// xatolikni har bir chaqiruvchi ekran o'zi `try/catch` bilan ushlaydi va
/// navigatsiyani ham o'zi hal qiladi.
class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> register({required String email, required String password}) async {
    state = true;
    try {
      await ref.read(registerUseCaseProvider).call(email: email, password: password);
      // Yangi hisob — oldingi sessiyadan qolgan keshni tozalab, "eski
      // foydalanuvchi ko'rinib turishi" xatosining oldini olamiz.
      resetUserScopedState(ref);
    } finally {
      state = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = true;
    try {
      await ref.read(loginUseCaseProvider).call(email: email, password: password);
      resetUserScopedState(ref);
    } finally {
      state = false;
    }
  }

  /// Google hisob tanlagichini ochadi. Foydalanuvchi hech kimni
  /// tanlamasdan yopsa `null` qaytaradi (xato emas, chaqiruvchi hech
  /// narsa qilmasligi kerak).
  Future<User?> signInWithGoogle() async {
    state = true;
    try {
      final User? user = await ref.read(signInWithGoogleUseCaseProvider).call();
      // Faqat haqiqatan kirilgan bo'lsa tozalanadi — bekor qilinsa (null)
      // hozirgi holat o'zgarmasligi kerak.
      if (user != null) resetUserScopedState(ref);
      return user;
    } finally {
      state = false;
    }
  }

  Future<void> logout() async {
    state = true;
    try {
      await ref.read(logoutUseCaseProvider).call();
    } finally {
      // Server so'rovi muvaffaqiyatsiz bo'lsa ham lokal holat tozalanadi —
      // foydalanuvchi qurilmada baribir chiqqan hisoblanadi.
      resetUserScopedState(ref);
      state = false;
    }
  }

  /// `PATCH /users/me/profile`ni chaqiradi — Onboarding'ni yakunlash uchun
  /// ham, Profilni tahrirlash uchun ham ishlatiladi. Muvaffaqiyatli
  /// bo'lsa yangilangan [User]ni qaytaradi — chaqiruvchi buni
  /// `currentUserControllerProvider`ga o'zi yozishi kerak.
  Future<User> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    String? avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  }) async {
    state = true;
    try {
      return await ref.read(updateProfileUseCaseProvider).call(
            username: username,
            firstName: firstName,
            lastName: lastName,
            avatarColor: avatarColor,
            direction: direction,
            interests: interests,
            studyPlace: studyPlace,
            quizLiking: quizLiking,
          );
    } finally {
      state = false;
    }
  }

  /// `POST /users/me/avatar`ni chaqiradi — tanlangan rasmni yuklaydi.
  /// Muvaffaqiyatli bo'lsa yangilangan [User]ni qaytaradi — chaqiruvchi
  /// buni `currentUserControllerProvider`ga o'zi yozishi kerak.
  Future<User> uploadAvatarImage(String filePath) async {
    state = true;
    try {
      return await ref.read(uploadAvatarImageUseCaseProvider).call(filePath);
    } finally {
      state = false;
    }
  }

  /// `POST /auth/change-password`ni chaqiradi.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    state = true;
    try {
      await ref.read(changePasswordUseCaseProvider).call(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
    } finally {
      state = false;
    }
  }

  /// `DELETE /auth/me`ni chaqiradi — muvaffaqiyatli bo'lsa lokal tokenlar
  /// ham tozalanadi. [password] Google hisoblar uchun null.
  Future<void> deleteAccount(String? password) async {
    state = true;
    try {
      await ref.read(deleteAccountUseCaseProvider).call(password);
      // Hisob o'chirildi — barcha keshlangan holat ham tozalanishi kerak.
      resetUserScopedState(ref);
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<AuthController, bool> authControllerProvider =
    NotifierProvider<AuthController, bool>(AuthController.new);
