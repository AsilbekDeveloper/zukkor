import 'rank_entry.dart';

/// `GET /leaderboard/category/{id}`'s response — reyting faqat shu
/// kategoriyada to'plangan XP bo'yicha. [RankEntry.totalXp] bu yerda
/// kategoriya XP'sini saqlaydi, umumiy (lifetime) XP emas — darajani
/// [RankEntry] o'zi hisoblamagani uchun chalkashlik yo'q.
class CategoryLeaderboardData {
  const CategoryLeaderboardData({
    required this.categoryId,
    required this.categoryName,
    required this.entries,
    required this.me,
    this.hasMore = false,
  });

  final int categoryId;
  final String categoryName;
  final List<RankEntry> entries;

  /// Foydalanuvchi shu kategoriyada hali hech qachon o'ynamagan bo'lsa
  /// `null` — reytingda umuman qatori yo'q.
  final RankEntry? me;
  final bool hasMore;
}
