import '../entities/session_history_entry.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  const GetHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<({List<SessionHistoryEntry> entries, bool hasMore})> call({int limit = 50, int offset = 0}) =>
      _repository.getHistory(limit: limit, offset: offset);
}
