import '../entities/session_history_entry.dart';

abstract interface class HistoryRepository {
  Future<List<SessionHistoryEntry>> getHistory({int limit = 50});
}
