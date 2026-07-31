import '../../domain/entities/question_breakdown_item.dart';
import 'quiz_category.dart';

/// The outcome of a finished quiz session — passed as the `/result`
/// route's `extra` from [QuizScreen] once every question is answered.
class QuizResult {
  const QuizResult({
    required this.category,
    required this.correctCount,
    required this.totalCount,
    required this.xpEarned,
    required this.totalBall,
    required this.breakdown,
  });

  final QuizCategory category;
  final int correctCount;
  final int totalCount;
  final int xpEarned;
  final List<QuestionBreakdownItem> breakdown;

  /// Sum of every question's ball (0 for wrong/timeout, up to ~1000 for a
  /// near-instant correct answer) — what [BallRevealScreen] counts up and
  /// [ResultScreen] shows alongside the XP it converts into.
  final int totalBall;

  /// Same as [totalCount] — kept as a separate name so "Play again" reads
  /// intent (how many questions to ask again) rather than a result field.
  int get questionCount => totalCount;

  double get percent => totalCount == 0 ? 0 : correctCount / totalCount;
}
