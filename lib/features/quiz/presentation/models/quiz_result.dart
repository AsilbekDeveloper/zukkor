import 'quiz_category.dart';

/// The outcome of a finished quiz session — passed as the `/result`
/// route's `extra` from [QuizScreen] once every question is answered.
class QuizResult {
  const QuizResult({
    required this.category,
    required this.correctCount,
    required this.totalCount,
    required this.xpEarned,
  });

  final QuizCategory category;
  final int correctCount;
  final int totalCount;
  final int xpEarned;

  double get percent => totalCount == 0 ? 0 : correctCount / totalCount;
}
