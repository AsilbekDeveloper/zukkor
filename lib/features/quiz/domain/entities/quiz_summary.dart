import 'question_breakdown_item.dart';

/// Quiz sessiyasi yakunlangandagi hisobot — `answer` javobidagi
/// `summary` maydoniga mos.
class QuizSummary {
  const QuizSummary({
    required this.totalBall,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
    required this.newTotalXp,
    required this.breakdown,
  });

  final int totalBall;
  final int correctCount;
  final int totalQuestions;
  final int xpEarned;
  final int newTotalXp;
  final List<QuestionBreakdownItem> breakdown;
}
