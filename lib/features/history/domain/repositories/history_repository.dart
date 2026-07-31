import '../entities/session_history_entry.dart';

abstract interface class HistoryRepository {
  /// [hasMore] tells the caller whether another page exists past
  /// `offset + entries.length` — the paging cursor is a plain numeric
  /// offset, not an opaque token.
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0});
}
