import '../../domain/entities/quiz_question_data.dart';

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.sessionQuestionId,
    required this.questionText,
    required this.options,
    required this.order,
    required this.total,
    required this.timeLimitMs,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) => QuizQuestionModel(
        sessionQuestionId: json['session_question_id'] as int,
        questionText: json['question_text'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        order: json['order'] as int,
        total: json['total'] as int,
        timeLimitMs: json['time_limit_ms'] as int,
      );

  final int sessionQuestionId;
  final String questionText;
  final List<String> options;
  final int order;
  final int total;
  final int timeLimitMs;

  QuizQuestionData toEntity() => QuizQuestionData(
        sessionQuestionId: sessionQuestionId,
        questionText: questionText,
        options: options,
        order: order,
        total: total,
        timeLimitMs: timeLimitMs,
      );
}
