import '../entities/notification_preferences.dart';
import '../repositories/notification_preferences_repository.dart';

class GetNotificationPreferencesUseCase {
  const GetNotificationPreferencesUseCase(this._repository);

  final NotificationPreferencesRepository _repository;

  Future<NotificationPreferences> call() => _repository.getPreferences();
}
