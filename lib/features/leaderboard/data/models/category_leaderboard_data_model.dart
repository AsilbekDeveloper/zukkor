import '../../domain/entities/category_leaderboard_data.dart';
import '../../domain/entities/rank_entry.dart';

/// Backend `CategoryRankEntryOut`ni [RankEntry]ga moslaydi — maydon nomi
/// boshqacha (`category_xp`, `total_xp` emas) va `level`/`level_title`
/// umuman yo'q (ataylab — [CategoryLeaderboardData] izohiga qarang).
RankEntry _categoryRankEntryFromJson(Map<String, dynamic> json) => RankEntry(
  userId: json['user_id'] as String,
  rank: json['rank'] as int,
  username: json['username'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  avatarColor: json['avatar_color'] as String?,
  avatarImagePath: json['avatar_image_path'] as String?,
  totalXp: json['category_xp'] as int,
  isMe: json['is_me'] as bool,
);

class CategoryLeaderboardDataModel {
  const CategoryLeaderboardDataModel({
    required this.categoryId,
    required this.categoryName,
    required this.entries,
    required this.me,
    this.hasMore = false,
  });

  factory CategoryLeaderboardDataModel.fromJson(Map<String, dynamic> json) =>
      CategoryLeaderboardDataModel(
        categoryId: json['category_id'] as int,
        categoryName: json['category_name'] as String,
        entries: (json['entries'] as List<dynamic>)
            .map((e) => _categoryRankEntryFromJson(e as Map<String, dynamic>))
            .toList(),
        me: json['me'] == null
            ? null
            : _categoryRankEntryFromJson(json['me'] as Map<String, dynamic>),
        hasMore: json['has_more'] as bool? ?? false,
      );

  final int categoryId;
  final String categoryName;
  final List<RankEntry> entries;
  final RankEntry? me;
  final bool hasMore;

  CategoryLeaderboardData toEntity() => CategoryLeaderboardData(
    categoryId: categoryId,
    categoryName: categoryName,
    entries: entries,
    me: me,
    hasMore: hasMore,
  );
}
