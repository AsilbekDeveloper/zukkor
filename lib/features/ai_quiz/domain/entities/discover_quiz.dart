/// Boshqa foydalanuvchilar yaratgan va ommaga/do'stlarga ochiq bo'lgan quiz.
class DiscoverQuiz {
  const DiscoverQuiz({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
    required this.source,
    required this.visibility,
    required this.ownerUserId,
    this.ownerUsername,
    this.topicCategoryId,
    this.topicCategoryName,
  });

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;

  /// 'ai_document' | 'ai_topic' | 'manual'
  final String source;

  /// 'friends' | 'public'
  final String visibility;

  final String ownerUserId;
  final String? ownerUsername;

  final int? topicCategoryId;
  final String? topicCategoryName;
}
