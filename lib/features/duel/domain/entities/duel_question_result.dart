/// `duel_question_result` — sent once both players have answered (or
/// timed out) for a question: reveals the correct option and both
/// sides' picks, right before the server pushes the next question.
class DuelQuestionResult {
  const DuelQuestionResult({
    required this.duelId,
    required this.questionIndex,
    required this.correctOption,
    required this.yourSelectedOption,
    required this.yourCorrect,
    required this.opponentSelectedOption,
    required this.opponentCorrect,
  });

  final String duelId;
  final int questionIndex;
  final int correctOption;
  final int? yourSelectedOption;
  final bool yourCorrect;
  final int? opponentSelectedOption;
  final bool opponentCorrect;
}
