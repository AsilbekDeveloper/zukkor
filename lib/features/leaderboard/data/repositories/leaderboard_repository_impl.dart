import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';
import '../../domain/entities/player_stats.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/usecases/get_leaderboard_use_case.dart';
import '../../domain/usecases/get_player_stats_use_case.dart';
import '../datasources/leaderboard_remote_data_source.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl({required LeaderboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async {
    try {
      return (await _remoteDataSource.getLeaderboard(limit: limit, scope: scope, offset: offset)).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<PlayerStats> getPlayerStats(String userId) async {
    try {
      return (await _remoteDataSource.getPlayerStats(userId)).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<LeaderboardRepository> leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepositoryImpl(remoteDataSource: ref.watch(leaderboardRemoteDataSourceProvider)),
);

final Provider<GetLeaderboardUseCase> getLeaderboardUseCaseProvider = Provider<GetLeaderboardUseCase>(
  (ref) => GetLeaderboardUseCase(ref.watch(leaderboardRepositoryProvider)),
);

final Provider<GetPlayerStatsUseCase> getPlayerStatsUseCaseProvider = Provider<GetPlayerStatsUseCase>(
  (ref) => GetPlayerStatsUseCase(ref.watch(leaderboardRepositoryProvider)),
);
