import '../../domain/entities/discover_quiz.dart';

class DiscoverQuizModel {
  const DiscoverQuizModel({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
    required this.source,
    required this.visibility,
    required this.ownerUserId,
    this.ownerUsername,
  });

  factory DiscoverQuizModel.fromJson(Map<String, dynamic> json) => DiscoverQuizModel(
        id: json['id'] as int,
        name: json['name'] as String,
        questionCount: json['question_count'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        source: json['source'] as String,
        visibility: json['visibility'] as String,
        ownerUserId: json['owner_user_id'] as String,
        ownerUsername: json['owner_username'] as String?,
      );

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;
  final String source;
  final String visibility;
  final String ownerUserId;
  final String? ownerUsername;

  DiscoverQuiz toEntity() => DiscoverQuiz(
        id: id,
        name: name,
        questionCount: questionCount,
        createdAt: createdAt,
        source: source,
        visibility: visibility,
        ownerUserId: ownerUserId,
        ownerUsername: ownerUsername,
      );
}
