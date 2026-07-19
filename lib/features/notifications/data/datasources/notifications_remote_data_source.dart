import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_record_model.dart';

/// `/notifications` endpointiga xom (Dio) so'rovlar. Xatolikni ushlamaydi
/// — [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni [Failure]ga
/// aylantirish repository'ning ishi.
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<NotificationRecordModel>> getNotifications() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.notifications);
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return (data['entries'] as List<dynamic>)
        .map((json) => NotificationRecordModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() => _dio.post<void>(ApiEndpoints.notificationsMarkAllRead);
}

final Provider<NotificationsRemoteDataSource> notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>(
  (ref) => NotificationsRemoteDataSource(ref.watch(dioProvider)),
);
