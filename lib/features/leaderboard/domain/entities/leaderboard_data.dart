import 'rank_entry.dart';

/// `GET /leaderboard`'s response — the ranked list plus the caller's own
/// entry, which is always present even when their rank falls outside
/// [entries].
class LeaderboardData {
  const LeaderboardData({required this.entries, required this.me, this.hasMore = false});

  final List<RankEntry> entries;
  final RankEntry me;

  /// Whether another page exists past `entries.length` — a plain
  /// numeric offset cursor, not an opaque token.
  final bool hasMore;
}
