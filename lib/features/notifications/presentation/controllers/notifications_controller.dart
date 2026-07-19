import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_record.dart';

/// `GET /notifications`. [load] must be called when the screen opens (not
/// automatic); a failed [load] leaves `state` null — matches the
/// silent-catch pattern used by other "just show data" screens.
class NotificationsController extends Notifier<List<NotificationRecord>?> {
  @override
  List<NotificationRecord>? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getNotificationsUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — pastga qarang.
    }
  }

  /// Optimistically marks every loaded entry as read, then confirms with
  /// the server — matches the existing "visiting clears the bell badge"
  /// behavior. A failed call leaves the optimistic (already-read) state
  /// in place rather than reverting, since re-showing stale unread dots
  /// after the user has already seen them would be more confusing than
  /// helpful.
  Future<void> markAllRead() async {
    final List<NotificationRecord>? current = state;
    if (current == null || current.every((n) => n.isRead)) return;
    state = [
      for (final entry in current)
        NotificationRecord(id: entry.id, kind: entry.kind, createdAt: entry.createdAt, isRead: true),
    ];
    try {
      await ref.read(markAllNotificationsReadUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — yuqoridagi izohga qarang.
    }
  }
}

final NotifierProvider<NotificationsController, List<NotificationRecord>?> notificationsControllerProvider =
    NotifierProvider<NotificationsController, List<NotificationRecord>?>(NotificationsController.new);
