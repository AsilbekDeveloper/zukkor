import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/leaderboard_scope.dart';
import '../models/leaderboard_data_model.dart';
import '../models/player_stats_model.dart';

/// `/leaderboard*` endpoint'lariga xom (Dio) so'rovlar. Xatolikni
/// ushlamaydi — [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni
/// [Failure]ga aylantirish [LeaderboardRepositoryImpl]ning ishi.
class LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LeaderboardDataModel> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async {
    final Response<dynamic> response =
        await _dio.get(ApiEndpoints.leaderboard(limit: limit, scope: _scopeParam(scope), offset: offset));
    return LeaderboardDataModel.fromJson(response.data as Map<String, dynamic>);
  }

  static String _scopeParam(LeaderboardScope scope) => switch (scope) {
        LeaderboardScope.weekly => 'weekly',
        LeaderboardScope.allTime => 'all_time',
        LeaderboardScope.friends => 'friends',
      };

  Future<PlayerStatsModel> getPlayerStats(String userId) async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.playerStats(userId));
    return PlayerStatsModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final Provider<LeaderboardRemoteDataSource> leaderboardRemoteDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>(
  (ref) => LeaderboardRemoteDataSource(ref.watch(dioProvider)),
);
