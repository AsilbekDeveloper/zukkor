import '../entities/notification_record.dart';

abstract interface class NotificationsRepository {
  /// `GET /notifications`.
  Future<List<NotificationRecord>> getNotifications();

  /// `POST /notifications/mark-all-read` — called once the inbox screen
  /// is opened, matching the existing "visiting clears the bell badge"
  /// behavior.
  Future<void> markAllRead();
}
