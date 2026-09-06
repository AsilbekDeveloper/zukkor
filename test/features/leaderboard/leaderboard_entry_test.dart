import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/presentation/models/leaderboard_entry.dart';

RankEntry _entry({required int rank, required int totalXp, bool isMe = false}) => RankEntry(
      userId: 'user-$rank',
      rank: rank,
      username: 'user$rank',
      firstName: null,
      lastName: null,
      avatarColor: 'a-coral',
      avatarImagePath: null,
      totalXp: totalXp,
      isMe: isMe,
    );

void main() {
  test('rankedWithMe inserts "me" at its sorted position, not always last', () {
    // Regression: Friends scope returns friends and "me" as two separate
    // fields - "me" used to always be appended at the end regardless of
    // rank, so a current user who outranked every friend still rendered
    // dead last (2026-09-06, reported from a live device screenshot).
    final data = LeaderboardData(
      entries: [_entry(rank: 2, totalXp: 114), _entry(rank: 3, totalXp: 69)],
      me: _entry(rank: 1, totalXp: 322, isMe: true),
    );

    final ranked = data.rankedWithMe;

    expect(ranked.map((e) => e.rank).toList(), [1, 2, 3]);
    expect(ranked.first.isCurrentUser, isTrue);
  });

  test('rankedWithMe still appends "me" last when they rank worst', () {
    final data = LeaderboardData(
      entries: [_entry(rank: 1, totalXp: 500), _entry(rank: 2, totalXp: 300)],
      me: _entry(rank: 3, totalXp: 10, isMe: true),
    );

    final ranked = data.rankedWithMe;

    expect(ranked.map((e) => e.rank).toList(), [1, 2, 3]);
    expect(ranked.last.isCurrentUser, isTrue);
  });

  test('rankedWithMe does not duplicate "me" when already present in entries', () {
    final data = LeaderboardData(
      entries: [_entry(rank: 1, totalXp: 500, isMe: true), _entry(rank: 2, totalXp: 300)],
      me: _entry(rank: 1, totalXp: 500, isMe: true),
    );

    final ranked = data.rankedWithMe;

    expect(ranked.length, 2);
    expect(ranked.where((e) => e.isCurrentUser).length, 1);
  });
}
