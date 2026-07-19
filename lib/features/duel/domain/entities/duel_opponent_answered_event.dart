/// `duel_opponent_answered` — tells the other player their opponent has
/// locked in an answer for the current question (no content revealed).
class DuelOpponentAnsweredEvent {
  const DuelOpponentAnsweredEvent({required this.duelId, required this.questionIndex});

  final String duelId;
  final int questionIndex;
}
