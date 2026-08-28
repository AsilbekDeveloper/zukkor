import '../../domain/entities/rank_entry.dart';

class RankEntryModel {
  const RankEntryModel({
    required this.userId,
    required this.rank,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.totalXp,
    required this.isMe,
  });

  factory RankEntryModel.fromJson(Map<String, dynamic> json) => RankEntryModel(
        userId: json['user_id'] as String,
        rank: json['rank'] as int,
        username: json['username'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        avatarColor: json['avatar_color'] as String?,
        avatarImagePath: json['avatar_image_path'] as String?,
        totalXp: json['total_xp'] as int,
        isMe: json['is_me'] as bool,
      );

  final String userId;
  final int rank;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final int totalXp;
  final bool isMe;

  RankEntry toEntity() => RankEntry(
        userId: userId,
        rank: rank,
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        avatarImagePath: avatarImagePath,
        totalXp: totalXp,
        isMe: isMe,
      );
}
