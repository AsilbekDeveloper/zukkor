import '../../domain/entities/ai_quiz.dart';

class AiQuizModel {
  const AiQuizModel({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
    required this.source,
    required this.visibility,
    this.topicCategoryId,
    this.topicCategoryName,
    this.diamondCost,
  });

  factory AiQuizModel.fromJson(Map<String, dynamic> json) => AiQuizModel(
        id: json['id'] as int,
        name: json['name'] as String,
        questionCount: json['question_count'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        source: json['source'] as String,
        visibility: json['visibility'] as String,
        topicCategoryId: json['topic_category_id'] as int?,
        topicCategoryName: json['topic_category_name'] as String?,
        diamondCost: json['diamond_cost'] as int?,
      );

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;
  final String source;
  final String visibility;
  final int? topicCategoryId;
  final String? topicCategoryName;
  final int? diamondCost;

  AiQuiz toEntity() => AiQuiz(
        id: id,
        name: name,
        questionCount: questionCount,
        createdAt: createdAt,
        source: source,
        visibility: visibility,
        topicCategoryId: topicCategoryId,
        topicCategoryName: topicCategoryName,
        diamondCost: diamondCost,
      );
}
