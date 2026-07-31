/// `duel_question_result` — sent to this player alone once they've
/// answered (or timed out) their own current question: reveals the
/// correct option and their own pick, right before the server pushes
/// their next question. Duel now runs at each player's own pace, so
/// there's no "opponent's pick" to reveal alongside it anymore.
class DuelQuestionResult {
  const DuelQuestionResult({
    required this.duelId,
    required this.questionIndex,
    required this.correctOption,
    required this.yourSelectedOption,
    required this.yourCorrect,
  });

  final String duelId;
  final int questionIndex;
  final int correctOption;
  final int? yourSelectedOption;
  final bool yourCorrect;
}
