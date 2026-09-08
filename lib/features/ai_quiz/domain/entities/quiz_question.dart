/// One question of a quiz the caller owns — currently only ever returned
/// for `source == 'manual'` quizzes (see [[EditManualQuizScreen]]).
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  final int id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
}
