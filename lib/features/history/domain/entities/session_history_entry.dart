/// Which mode a past `/history` entry was played in.
enum HistorySessionMode { solo, duel, lobby }

enum DuelHistoryOutcome { won, lost, draw }

/// The opponent shown on a duel history row — a small user summary, only
/// present when [SessionHistoryEntry.mode] is [HistorySessionMode.duel].
class DuelHistoryOpponent {
  const DuelHistoryOpponent({
    required this.name,
    required this.avatarColor,
    required this.avatarImagePath,
  });

  final String name;
  final String? avatarColor;
  final String? avatarImagePath;
}

/// This player's placement in a finished lobby room — only present when
/// [SessionHistoryEntry.mode] is [HistorySessionMode.lobby].
class LobbyHistoryResult {
  const LobbyHistoryResult({required this.rank, required this.participantCount});

  /// 1-based — 1 is first place.
  final int rank;
  final int participantCount;
}

/// One row of the `/history` response — a past, finished quiz session,
/// solo or duel.
class SessionHistoryEntry {
  const SessionHistoryEntry({
    required this.sessionId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconName,
    required this.categoryColorKey,
    required this.finishedAt,
    required this.correctCount,
    required this.totalQuestions,
    required this.totalBall,
    required this.totalXpEarned,
    required this.mode,
    this.opponent,
    this.duelOutcome,
    this.lobbyResult,
  });

  final String sessionId;
  final int categoryId;
  final String categoryName;
  final String categoryIconName;
  final String categoryColorKey;
  final DateTime finishedAt;
  final int correctCount;
  final int totalQuestions;
  final int totalBall;
  final int totalXpEarned;
  final HistorySessionMode mode;

  /// Non-null only when [mode] is [HistorySessionMode.duel].
  final DuelHistoryOpponent? opponent;

  /// Non-null only when [mode] is [HistorySessionMode.duel].
  final DuelHistoryOutcome? duelOutcome;

  /// Non-null only when [mode] is [HistorySessionMode.lobby].
  final LobbyHistoryResult? lobbyResult;
}
