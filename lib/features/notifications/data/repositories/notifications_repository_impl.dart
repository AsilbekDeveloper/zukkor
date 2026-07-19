import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/notification_record.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<NotificationRecord>> getNotifications() async {
    try {
      final models = await _remoteDataSource.getNotifications();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _remoteDataSource.markAllRead();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<NotificationsRepository> notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(ref.watch(notificationsRemoteDataSourceProvider)),
);

final Provider<GetNotificationsUseCase> getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>(
  (ref) => GetNotificationsUseCase(ref.watch(notificationsRepositoryProvider)),
);

final Provider<MarkAllNotificationsReadUseCase> markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>(
  (ref) => MarkAllNotificationsReadUseCase(ref.watch(notificationsRepositoryProvider)),
);
