/// Serverdan kelgan bitta savol.
class QuizQuestionData {
  const QuizQuestionData({
    required this.sessionQuestionId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.order,
    required this.total,
    required this.timeLimitMs,
  });

  final int sessionQuestionId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int order;
  final int total;
  final int timeLimitMs;
}
