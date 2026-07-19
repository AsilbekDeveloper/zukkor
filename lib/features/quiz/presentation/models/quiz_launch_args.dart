import 'quiz_category.dart';

/// [QuizIntroScreen] and [QuizScreen]'s route `extra` — a category plus
/// how many questions to ask.
class QuizLaunchArgs {
  const QuizLaunchArgs({
    required this.category,
    this.questionCount = 10,
  });

  final QuizCategory category;
  final int questionCount;
}
