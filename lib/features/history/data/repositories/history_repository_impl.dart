import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/session_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/get_history_use_case.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({required HistoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final HistoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<SessionHistoryEntry>> getHistory({int limit = 50}) async {
    try {
      final models = await _remoteDataSource.getHistory(limit: limit);
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<HistoryRepository> historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(remoteDataSource: ref.watch(historyRemoteDataSourceProvider)),
);

final Provider<GetHistoryUseCase> getHistoryUseCaseProvider = Provider<GetHistoryUseCase>(
  (ref) => GetHistoryUseCase(ref.watch(historyRepositoryProvider)),
);
