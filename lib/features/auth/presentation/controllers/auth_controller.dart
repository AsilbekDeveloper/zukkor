import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';

/// Login/Register/Logout amallarini boshqaradi. Holati (`AsyncValue<void>`)
/// ekranlarda yuklanish spinneri ko'rsatish va xatolikni o'qish uchun
/// ishlatiladi — muvaffaqiyat/xatolikdan keyingi navigatsiyani ekranning
/// o'zi (chaqiruvchi) hal qiladi.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(registerUseCaseProvider).call(
            email: email,
            username: username,
            password: password,
          ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loginUseCaseProvider).call(email: email, password: password),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(logoutUseCaseProvider).call());
  }
}

final AsyncNotifierProvider<AuthController, void> authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
