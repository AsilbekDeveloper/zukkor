import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

/// Joriy tizimga kirgan foydalanuvchi ma'lumotlari — `GET /auth/me`.
/// Ekran ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi);
/// muvaffaqiyatsiz bo'lsa `state.hasError` `true` bo'ladi — token muddati
/// o'tgan holatni [SessionExpiredNotifier] alohida boshqaradi.
class CurrentUserController extends Notifier<LoadState<User>> {
  @override
  LoadState<User> build() => const LoadState();

  Future<void> load() async {
    debugPrint('[ZUKKOR-DIAG] CurrentUserController.load() chaqirildi');
    state = const LoadState();
    try {
      final user = await ref.read(getCurrentUserUseCaseProvider).call();
      debugPrint('[ZUKKOR-DIAG] CurrentUserController.load() muvaffaqiyatli: ${user.id}, ${user.username}');
      state = LoadState(data: user);
    } catch (e, st) {
      debugPrint('[ZUKKOR-DIAG] CurrentUserController.load() XATO: $e\n$st');
      state = const LoadState(hasError: true);
    }
  }

  /// Boshqa bir so'rov (masalan `updateProfile`) allaqachon yangilangan
  /// foydalanuvchini qaytargan bo'lsa, qayta tarmoqqa murojaat qilmasdan
  /// darhol shu bilan almashtirish uchun.
  void setUser(User user) => state = LoadState(data: user);
}

final NotifierProvider<CurrentUserController, LoadState<User>> currentUserControllerProvider =
    NotifierProvider<CurrentUserController, LoadState<User>>(CurrentUserController.new);
