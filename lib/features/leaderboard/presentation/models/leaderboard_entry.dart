import 'package:flutter/widgets.dart';

import '../../../../core/models/avatar_color_option.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../../domain/entities/player_stats.dart';
import '../../domain/entities/rank_entry.dart';

/// One row on the leaderboard — mirrors the prototype's `.rank-row` /
/// `.pod` data (rank, avatar, name, XP). Built from the real
/// `GET /leaderboard` entities via [LeaderboardEntry.fromEntity]. [id] is
/// the backend user id — null only for [LobbyResultScreen]'s mock room
/// standings, which aren't real users and so can't open a
/// [PlayerDetailScreen].
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.initials,
    required this.xp,
    required this.avatarColor,
    this.avatarImagePath,
    this.id,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromEntity(RankEntry entity) => LeaderboardEntry(
        id: entity.userId,
        rank: entity.rank,
        name: _displayName(
          firstName: entity.firstName,
          lastName: entity.lastName,
          username: entity.username,
        ),
        initials: _initials(firstName: entity.firstName, lastName: entity.lastName),
        xp: entity.totalXp,
        avatarColor: AvatarColorOption.fromApiValue(entity.avatarColor),
        avatarImagePath: entity.avatarImagePath,
        isCurrentUser: entity.isMe,
      );

  /// Builds a row from `GET /leaderboard/{user_id}` — used by
  /// [PlayerDetailScreen] to paint its header once stats arrive, for
  /// callers (Friends, Add Friend, Friend Requests) that don't already
  /// have a [LeaderboardEntry] on hand the way a Leaderboard row tap does.
  factory LeaderboardEntry.fromPlayerStats(PlayerStats stats) => LeaderboardEntry(
        id: stats.userId,
        rank: stats.rank,
        name: _displayName(firstName: stats.firstName, lastName: stats.lastName, username: stats.username),
        initials: _initials(firstName: stats.firstName, lastName: stats.lastName),
        xp: stats.totalXp,
        avatarColor: AvatarColorOption.fromApiValue(stats.avatarColor),
        avatarImagePath: stats.avatarImagePath,
      );

  final String? id;
  final int rank;
  final String name;
  final String initials;
  final int xp;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;

  /// Drives the "me" row styling (dark background) — matches the
  /// prototype's `.rank-row.me`.
  final bool isCurrentUser;

  static String _displayName({
    required String? firstName,
    required String? lastName,
    required String? username,
  }) {
    final String name =
        [firstName, lastName].where((part) => part != null && part.isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    if (username != null && username.isNotEmpty) return username;
    // No first/last name and no username yet — earned XP before ever
    // completing onboarding.
    return t.leaderboard.anonymousPlayer;
  }

  static String _initials({required String? firstName, required String? lastName}) {
    final String first = (firstName?.isNotEmpty ?? false) ? firstName![0] : '';
    final String last = (lastName?.isNotEmpty ?? false) ? lastName![0] : '';
    final String combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }
}

extension LeaderboardEntryDisplayName on LeaderboardEntry {
  /// The current user's own row always shows the translated "You".
  String displayName(BuildContext context) =>
      isCurrentUser ? context.t.leaderboard.you : name;
}

extension LeaderboardDataRankedWithMe on LeaderboardData {
  /// [entries] converted, plus the caller's own entry appended at the
  /// end — unless they're already ranked highly enough to be in
  /// [entries], in which case it isn't duplicated.
  List<LeaderboardEntry> get rankedWithMe {
    final List<LeaderboardEntry> ranked = entries.map(LeaderboardEntry.fromEntity).toList();
    if (ranked.any((entry) => entry.isCurrentUser)) return ranked;
    return [...ranked, LeaderboardEntry.fromEntity(me)];
  }
}
