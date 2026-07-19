import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../../domain/usecases/get_notification_preferences_use_case.dart';
import '../../domain/usecases/update_notification_preferences_use_case.dart';
import '../datasources/notification_preferences_remote_data_source.dart';
import '../models/notification_preferences_model.dart';

class NotificationPreferencesRepositoryImpl implements NotificationPreferencesRepository {
  const NotificationPreferencesRepositoryImpl(this._remoteDataSource);

  final NotificationPreferencesRemoteDataSource _remoteDataSource;

  @override
  Future<NotificationPreferences> getPreferences() async {
    try {
      return (await _remoteDataSource.getPreferences()).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences) async {
    try {
      return (await _remoteDataSource.updatePreferences(NotificationPreferencesModel.fromEntity(preferences)))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<NotificationPreferencesRepository> notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>(
  (ref) => NotificationPreferencesRepositoryImpl(ref.watch(notificationPreferencesRemoteDataSourceProvider)),
);

final Provider<GetNotificationPreferencesUseCase> getNotificationPreferencesUseCaseProvider =
    Provider<GetNotificationPreferencesUseCase>(
  (ref) => GetNotificationPreferencesUseCase(ref.watch(notificationPreferencesRepositoryProvider)),
);

final Provider<UpdateNotificationPreferencesUseCase> updateNotificationPreferencesUseCaseProvider =
    Provider<UpdateNotificationPreferencesUseCase>(
  (ref) => UpdateNotificationPreferencesUseCase(ref.watch(notificationPreferencesRepositoryProvider)),
);
