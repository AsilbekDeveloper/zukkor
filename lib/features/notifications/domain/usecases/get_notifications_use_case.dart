import '../entities/notification_record.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationRecord>> call() => _repository.getNotifications();
}
