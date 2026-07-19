/// Serverdan kelgan bitta savol — `correct_option_index` bu yerda YO'Q,
/// backend uni javob berilmaguncha oshkor qilmaydi.
class QuizQuestionData {
  const QuizQuestionData({
    required this.sessionQuestionId,
    required this.questionText,
    required this.options,
    required this.order,
    required this.total,
    required this.timeLimitMs,
  });

  final int sessionQuestionId;
  final String questionText;
  final List<String> options;
  final int order;
  final int total;
  final int timeLimitMs;
}
