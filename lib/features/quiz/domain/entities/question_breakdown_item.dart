/// One question's outcome in a finished game's per-question breakdown —
/// shared shape across Solo, Duel, and Lobby results.
class QuestionBreakdownItem {
  const QuestionBreakdownItem({
    required this.order,
    required this.questionId,
    required this.questionText,
    required this.isCorrect,
  });

  final int order;
  final int questionId;
  final String questionText;
  final bool isCorrect;
}
