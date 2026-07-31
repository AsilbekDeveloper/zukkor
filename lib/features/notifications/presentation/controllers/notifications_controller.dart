import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/notification_record.dart';

/// `GET /notifications`. [load] must be called when the screen opens (not
/// automatic); a failed [load] sets `state.hasError` instead of leaving
/// the screen stuck on its loading skeleton forever.
class NotificationsController extends Notifier<LoadState<List<NotificationRecord>>> {
  @override
  LoadState<List<NotificationRecord>> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(getNotificationsUseCaseProvider).call());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }

  /// Optimistically marks every loaded entry as read, then confirms with
  /// the server — matches the existing "visiting clears the bell badge"
  /// behavior. A failed call leaves the optimistic (already-read) state
  /// in place rather than reverting, since re-showing stale unread dots
  /// after the user has already seen them would be more confusing than
  /// helpful.
  Future<void> markAllRead() async {
    final List<NotificationRecord>? current = state.data;
    if (current == null || current.every((n) => n.isRead)) return;
    state = LoadState(
      data: [
        for (final entry in current)
          NotificationRecord(
            id: entry.id,
            kind: entry.kind,
            createdAt: entry.createdAt,
            isRead: true,
            relatedUserName: entry.relatedUserName,
          ),
      ],
    );
    try {
      await ref.read(markAllNotificationsReadUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — yuqoridagi izohga qarang.
    }
  }
}

final NotifierProvider<NotificationsController, LoadState<List<NotificationRecord>>>
    notificationsControllerProvider =
    NotifierProvider<NotificationsController, LoadState<List<NotificationRecord>>>(
        NotificationsController.new);
