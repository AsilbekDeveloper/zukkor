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
    this.topicCategoryId,
    this.topicCategoryName,
    this.diamondCost,
  });

  final int id;
  final String name;
  final int questionCount;
  final DateTime createdAt;

  /// 'ai_document' | 'ai_topic' | 'manual'
  final String source;

  /// 'private' | 'friends' | 'public'
  final String visibility;

  final int? topicCategoryId;
  final String? topicCategoryName;

  /// Faqat generatsiyadan TO'G'RIDAN-TO'G'RI qaytgan javoblarda to'ladi
  /// (haqiqiy token sarfidan hisoblangan) - keyinchalik ro'yxat/discover
  /// orqali o'qilganda har doim null. [[ai_cost_architecture]].
  final int? diamondCost;
}
