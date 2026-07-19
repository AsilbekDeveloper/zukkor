import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_preferences_model.dart';

/// `/users/me/notification-preferences` endpointiga xom (Dio) so'rovlar.
/// Xatolikni ushlamaydi — [DioException] to'g'ridan-to'g'ri tashqariga
/// chiqadi, uni [Failure]ga aylantirish repository'ning ishi.
class NotificationPreferencesRemoteDataSource {
  const NotificationPreferencesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NotificationPreferencesModel> getPreferences() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.notificationPreferences);
    return NotificationPreferencesModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel model) async {
    final Response<dynamic> response = await _dio.patch(
      ApiEndpoints.notificationPreferences,
      data: model.toJson(),
    );
    return NotificationPreferencesModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final Provider<NotificationPreferencesRemoteDataSource> notificationPreferencesRemoteDataSourceProvider =
    Provider<NotificationPreferencesRemoteDataSource>(
  (ref) => NotificationPreferencesRemoteDataSource(ref.watch(dioProvider)),
);
