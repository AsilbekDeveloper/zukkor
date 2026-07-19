import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/session_history_entry_model.dart';

/// `/history` endpoint'iga xom (Dio) so'rov. Xatolikni ushlamaydi —
/// [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni [Failure]ga
/// aylantirish [HistoryRepositoryImpl]ning ishi.
class HistoryRemoteDataSource {
  const HistoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<SessionHistoryEntryModel>> getHistory({int limit = 50}) async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.history(limit: limit));
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return (data['entries'] as List<dynamic>)
        .map((json) => SessionHistoryEntryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final Provider<HistoryRemoteDataSource> historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>(
  (ref) => HistoryRemoteDataSource(ref.watch(dioProvider)),
);
