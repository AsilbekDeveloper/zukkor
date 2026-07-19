import 'quiz_question_data.dart';

/// `POST /quiz/start` javobi.
class QuizStartResult {
  const QuizStartResult({required this.sessionId, required this.question});

  final String sessionId;
  final QuizQuestionData question;
}
