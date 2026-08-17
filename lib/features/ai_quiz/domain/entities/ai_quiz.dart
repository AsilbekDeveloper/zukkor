/// Foydalanuvchi yaratgan (AI orqali yoki qo'lda) shaxsiy quiz — kimga
/// ko'rinishi [visibility] bilan boshqariladi.
class AiQuiz {
  const AiQuiz({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.createdAt,
    required this.source,
    required this.visibility,
  });

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;

  /// 'ai_document' | 'ai_topic' | 'manual'
  final String source;

  /// 'private' | 'friends' | 'public'
  final String visibility;
}
