import 'lobby_player_score.dart';

/// `lobby_game_finished` — the room's final standings, sent to every
/// player once the last question's result has settled. Unlike Duel's
/// won/lost/draw, a room has N players, so the outcome is a ranked list
/// rather than a single label.
class LobbyFinalResult {
  const LobbyFinalResult({
    required this.roomId,
    required this.standings,
    required this.xpEarned,
    required this.ballEarned,
  });

  final String roomId;

  /// Ordered best-to-worst (server-computed: correct count, then total
  /// time as a tiebreaker).
  final List<LobbyPlayerScore> standings;

  /// This player's own reward — same solo-quiz formula as everywhere
  /// else, computed server-side.
  final int xpEarned;
  final int ballEarned;
}
