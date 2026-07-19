import 'rank_entry.dart';

/// `GET /leaderboard`'s response — the ranked list plus the caller's own
/// entry, which is always present even when their rank falls outside
/// [entries].
class LeaderboardData {
  const LeaderboardData({required this.entries, required this.me});

  final List<RankEntry> entries;
  final RankEntry me;
}
