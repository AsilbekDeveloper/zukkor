import '../../domain/entities/answer_result.dart';
import 'quiz_question_model.dart';
import 'quiz_summary_model.dart';

class AnswerResponseModel {
  const AnswerResponseModel({
    required this.isCorrect,
    required this.correctOptionIndex,
    required this.ballEarned,
    this.nextQuestion,
    this.summary,
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) => AnswerResponseModel(
        isCorrect: json['correct'] as bool,
        correctOptionIndex: json['correct_option_index'] as int,
        ballEarned: json['ball_earned'] as int,
        nextQuestion: json['next_question'] == null
            ? null
            : QuizQuestionModel.fromJson(json['next_question'] as Map<String, dynamic>),
        summary: json['summary'] == null
            ? null
            : QuizSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      );

  final bool isCorrect;
  final int correctOptionIndex;
  final int ballEarned;
  final QuizQuestionModel? nextQuestion;
  final QuizSummaryModel? summary;

  AnswerResult toEntity() => AnswerResult(
        isCorrect: isCorrect,
        correctOptionIndex: correctOptionIndex,
        ballEarned: ballEarned,
        nextQuestion: nextQuestion?.toEntity(),
        summary: summary?.toEntity(),
      );
}
