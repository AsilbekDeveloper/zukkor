import '../entities/session_history_entry.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  const GetHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<List<SessionHistoryEntry>> call({int limit = 50}) => _repository.getHistory(limit: limit);
}
