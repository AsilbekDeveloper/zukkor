import '../../domain/entities/ai_quiz.dart';

class AiQuizModel {
  const AiQuizModel({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
  });

  factory AiQuizModel.fromJson(Map<String, dynamic> json) => AiQuizModel(
        id: json['id'] as int,
        name: json['name'] as String,
        questionCount: json['question_count'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;

  AiQuiz toEntity() => AiQuiz(id: id, name: name, questionCount: questionCount, createdAt: createdAt);
}
