import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../domain/entities/notification_preferences.dart';

/// `GET|PATCH /users/me/notification-preferences`. [load] must be called
/// when the screen opens (not automatic); a failed [load] sets
/// `state.hasError` instead of leaving the screen stuck on its loading
/// skeleton forever.
class NotificationPreferencesController extends Notifier<LoadState<NotificationPreferences>> {
  @override
  LoadState<NotificationPreferences> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(getNotificationPreferencesUseCaseProvider).call());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }

  /// Muvaffaqiyatli bo'lsa `state`ni yangilaydi. Xato tashlaydi —
  /// chaqiruvchi ekran o'zi ushlab, avvalgi (optimistik) holatni
  /// qaytarishi va xabar ko'rsatishi kerak.
  Future<void> update(NotificationPreferences preferences) async {
    state = LoadState(data: await ref.read(updateNotificationPreferencesUseCaseProvider).call(preferences));
  }
}

final NotifierProvider<NotificationPreferencesController, LoadState<NotificationPreferences>>
    notificationPreferencesControllerProvider =
    NotifierProvider<NotificationPreferencesController, LoadState<NotificationPreferences>>(
        NotificationPreferencesController.new);
