/// A single multiple-choice question — always exactly 4 [options],
/// [correctIndex] points at the correct one.
class QuizQuestion {
  const QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final String text;
  final List<String> options;
  final int correctIndex;
}
