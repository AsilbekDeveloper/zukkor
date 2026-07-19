/// Quiz sessiyasi yakunlangandagi hisobot — `answer` javobidagi
/// `summary` maydoniga mos.
class QuizSummary {
  const QuizSummary({
    required this.totalBall,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
    required this.newTotalXp,
  });

  final int totalBall;
  final int correctCount;
  final int totalQuestions;
  final int xpEarned;
  final int newTotalXp;
}
