/// `duel_opponent_progress` — a light-touch signal that the opponent has
/// moved on to a new question (not sent once they've finished all of
/// theirs). Duel runs at each player's own pace now, so this is purely
/// cosmetic — it doesn't gate anything, just lets the UI show roughly
/// where the opponent is.
class DuelOpponentProgressEvent {
  const DuelOpponentProgressEvent({required this.duelId, required this.opponentQuestionIndex});

  final String duelId;
  final int opponentQuestionIndex;
}
