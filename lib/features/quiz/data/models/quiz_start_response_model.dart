import '../../domain/entities/quiz_start_result.dart';
import 'quiz_question_model.dart';

class QuizStartResponseModel {
  const QuizStartResponseModel({required this.sessionId, required this.question});

  factory QuizStartResponseModel.fromJson(Map<String, dynamic> json) => QuizStartResponseModel(
        sessionId: json['session_id'] as String,
        question: QuizQuestionModel.fromJson(json['question'] as Map<String, dynamic>),
      );

  final String sessionId;
  final QuizQuestionModel question;

  QuizStartResult toEntity() => QuizStartResult(sessionId: sessionId, question: question.toEntity());
}
