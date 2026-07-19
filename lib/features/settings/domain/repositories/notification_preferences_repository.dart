import '../entities/notification_preferences.dart';

/// Notification preferences backend bilan ishlash shartnomasi.
abstract interface class NotificationPreferencesRepository {
  /// `GET /users/me/notification-preferences`.
  Future<NotificationPreferences> getPreferences();

  /// `PATCH /users/me/notification-preferences` — barcha 5 maydonni birga
  /// yuboradi (bitta toggle o'zgarsa ham), yangilangan holatni qaytaradi.
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences);
}
