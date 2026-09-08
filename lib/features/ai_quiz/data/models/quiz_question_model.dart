import '../../domain/entities/quiz_question.dart';

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      QuizQuestionModel(
        id: json['id'] as int,
        questionText: json['question_text'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctOptionIndex: json['correct_option_index'] as int,
      );

  final int id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion toEntity() => QuizQuestion(
    id: id,
    questionText: questionText,
    options: options,
    correctOptionIndex: correctOptionIndex,
  );
}
