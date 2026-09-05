import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

/// Faol foydalanuvchi ID'sining "signal" nusxasi — [AppPreferences] kabi
/// `authRepositoryProvider` zanjiriga KIRMAYDIGAN quyi darajadagi
/// provider'lar buni xavfsiz o'qishi uchun.
///
/// MUHIM: `appPreferencesProvider` (yoki boshqa hech kim) to'g'ridan-to'g'ri
/// [currentUserControllerProvider]ni O'QIMASLIGI KERAK, chunki
/// `authRepositoryProvider` (demak `appPreferencesProvider` ham, unga
/// bog'liq bo'lgani uchun) [getCurrentUserUseCaseProvider] orqali
/// [currentUserControllerProvider]ning O'ZI tomonidan o'qiladi —
/// `currentUserControllerProvider` → `appPreferencesProvider` bog'lanishi
/// aylanma bog'liqlik (`CircularDependencyError`) hosil qilib, HAR SAFAR
/// profil yuklashga urinishda darhol xato berardi (2026-09-06'da real
/// qurilmada topilgan, production'ni butunlay buzgan xato). Shu signal
/// esa hech narsaga bog'liq emas — faqat [CurrentUserController] uni
/// YANGILAYDI, xolos.
class ActiveUserIdSignalNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? userId) => state = userId;
}

final NotifierProvider<ActiveUserIdSignalNotifier, String?> activeUserIdSignalProvider =
    NotifierProvider<ActiveUserIdSignalNotifier, String?>(ActiveUserIdSignalNotifier.new);

/// Joriy tizimga kirgan foydalanuvchi ma'lumotlari — `GET /auth/me`.
/// Ekran ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi);
/// muvaffaqiyatsiz bo'lsa `state.hasError` `true` bo'ladi — token muddati
/// o'tgan holatni [SessionExpiredNotifier] alohida boshqaradi.
class CurrentUserController extends Notifier<LoadState<User>> {
  @override
  LoadState<User> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      final User user = await ref.read(getCurrentUserUseCaseProvider).call();
      state = LoadState(data: user);
      ref.read(activeUserIdSignalProvider.notifier).set(user.id);
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }

  /// Boshqa bir so'rov (masalan `updateProfile`) allaqachon yangilangan
  /// foydalanuvchini qaytargan bo'lsa, qayta tarmoqqa murojaat qilmasdan
  /// darhol shu bilan almashtirish uchun.
  void setUser(User user) {
    state = LoadState(data: user);
    ref.read(activeUserIdSignalProvider.notifier).state = user.id;
  }
}

final NotifierProvider<CurrentUserController, LoadState<User>> currentUserControllerProvider =
    NotifierProvider<CurrentUserController, LoadState<User>>(CurrentUserController.new);
