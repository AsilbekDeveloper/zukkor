import 'duel_player_score.dart';

enum DuelOutcome { won, lost, draw }

/// `duel_finished` — the server computes the outcome and sends each
/// player their own perspective directly (`"result": "won"|"lost"|
/// "draw"`), so the client never has to compare user ids itself.
class DuelFinalResult {
  const DuelFinalResult({
    required this.duelId,
    required this.outcome,
    required this.yourScore,
    required this.opponentScore,
    required this.xpEarned,
    required this.ballEarned,
  });

  final String duelId;
  final DuelOutcome outcome;
  final DuelPlayerScore yourScore;
  final DuelPlayerScore opponentScore;
  final int xpEarned;
  final int ballEarned;
}
