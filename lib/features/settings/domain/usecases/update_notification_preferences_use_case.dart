import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

class UpdateNotificationPreferencesUseCase {
  const UpdateNotificationPreferencesUseCase(this._repository);

  final NotificationPreferencesRepository _repository;

  Future<NotificationPreferences> call(NotificationPreferences preferences) =>
      _repository.updatePreferences(preferences);
}
