import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';

/// Login/Register/Logout/Onboarding amallarini boshqaradi. Holati — shunchaki
/// `isLoading` bayrog'i (ekranlarda spinner ko'rsatish uchun); xatolikni
/// har bir chaqiruvchi ekran o'zi `try/catch` bilan ushlaydi va
/// navigatsiyani ham o'zi hal qiladi.
class AuthController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> register({required String email, required String password}) async {
    state = true;
    try {
      await ref.read(registerUseCaseProvider).call(email: email, password: password);
    } finally {
      state = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = true;
    try {
      await ref.read(loginUseCaseProvider).call(email: email, password: password);
    } finally {
      state = false;
    }
  }

  Future<void> logout() async {
    state = true;
    try {
      await ref.read(logoutUseCaseProvider).call();
    } finally {
      state = false;
    }
  }

  Future<void> completeOnboarding({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
  }) async {
    state = true;
    try {
      await ref.read(completeOnboardingUseCaseProvider).call(
            username: username,
            firstName: firstName,
            lastName: lastName,
            avatarColor: avatarColor,
            direction: direction,
          );
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<AuthController, bool> authControllerProvider =
    NotifierProvider<AuthController, bool>(AuthController.new);
