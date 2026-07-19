import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../domain/entities/notification_preferences.dart';

/// `GET|PATCH /users/me/notification-preferences`. [load] must be called
/// when the screen opens (not automatic); a failed [load] leaves `state`
/// null (screen shows a spinner) — matches the silent-catch pattern used
/// by other "just show data" screens.
class NotificationPreferencesController extends Notifier<NotificationPreferences?> {
  @override
  NotificationPreferences? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getNotificationPreferencesUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — pastga qarang.
    }
  }

  /// Muvaffaqiyatli bo'lsa `state`ni yangilaydi. Xato tashlaydi —
  /// chaqiruvchi ekran o'zi ushlab, avvalgi (optimistik) holatni
  /// qaytarishi va xabar ko'rsatishi kerak.
  Future<void> update(NotificationPreferences preferences) async {
    state = await ref.read(updateNotificationPreferencesUseCaseProvider).call(preferences);
  }
}

final NotifierProvider<NotificationPreferencesController, NotificationPreferences?>
    notificationPreferencesControllerProvider =
    NotifierProvider<NotificationPreferencesController, NotificationPreferences?>(
        NotificationPreferencesController.new);
