import 'quiz_question_data.dart';
import 'quiz_summary.dart';

/// `POST /quiz/{session_id}/answer` javobi — ikki holatdan biri bo'ladi:
/// [nextQuestion] bor (davom etadi) yoki [summary] bor (sessiya tugadi).
/// Ikkalasi ham bir vaqtda bo'lmaydi.
class AnswerResult {
  const AnswerResult({
    required this.isCorrect,
    required this.correctOptionIndex,
    required this.ballEarned,
    this.nextQuestion,
    this.summary,
  });

  final bool isCorrect;
  final int correctOptionIndex;
  final int ballEarned;
  final QuizQuestionData? nextQuestion;
  final QuizSummary? summary;

  bool get isSessionComplete => summary != null;
}
