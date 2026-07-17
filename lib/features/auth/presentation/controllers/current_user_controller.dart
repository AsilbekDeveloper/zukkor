import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

/// Joriy tizimga kirgan foydalanuvchi ma'lumotlari — `GET /auth/me`.
/// Ekran ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi);
/// muvaffaqiyatsiz bo'lsa `state` eskicha (yoki `null`) qoladi — token
/// muddati o'tgan holatni [SessionExpiredNotifier] alohida boshqaradi.
class CurrentUserController extends Notifier<User?> {
  @override
  User? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getCurrentUserUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — pastga qarang.
    }
  }
}

final NotifierProvider<CurrentUserController, User?> currentUserControllerProvider =
    NotifierProvider<CurrentUserController, User?>(CurrentUserController.new);
