import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/avatar_color_option.dart';

/// One row on the leaderboard — mirrors the prototype's `.rank-row` /
/// `.pod` data (rank, avatar, name, XP). This is placeholder sample
/// data — once the `quiz`/`accounts` data layers exist, this comes from
/// a real leaderboard endpoint instead.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.initials,
    required this.xp,
    required this.avatarColor,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final String initials;
  final int xp;
  final AvatarColorOption avatarColor;

  /// Drives the "me" row styling (dark background) — matches the
  /// prototype's `.rank-row.me`.
  final bool isCurrentUser;

  /// Top 6 + the current user's own (much lower) rank — matches the
  /// prototype's leaderboard view exactly.
  static const List<LeaderboardEntry> sample = [
    LeaderboardEntry(
      rank: 1,
      name: 'Aziz K.',
      initials: 'AZ',
      xp: 4820,
      avatarColor: AvatarColorOption.coral,
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Malika',
      initials: 'MR',
      xp: 4510,
      avatarColor: AvatarColorOption.teal,
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Shohruh',
      initials: 'SH',
      xp: 4290,
      avatarColor: AvatarColorOption.terra,
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Dilnoza Rustamova',
      initials: 'DI',
      xp: 3980,
      avatarColor: AvatarColorOption.teal,
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Bekzod Xolmatov',
      initials: 'BX',
      xp: 3840,
      avatarColor: AvatarColorOption.terra,
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'Nilufar Yoqubova',
      initials: 'NY',
      xp: 3710,
      avatarColor: AvatarColorOption.pink,
    ),
    LeaderboardEntry(
      rank: 312,
      name: AppStrings.currentUserName,
      initials: 'AZ',
      xp: 2140,
      avatarColor: AvatarColorOption.coral,
      isCurrentUser: true,
    ),
  ];

  /// [sample] without the top 3 (they're shown on the podium instead).
  static List<LeaderboardEntry> get sampleRestOfList =>
      sample.where((e) => e.rank > 3).toList();

  /// [sample]'s top 3, in podium display order: 2nd, 1st, 3rd.
  static List<LeaderboardEntry> get samplePodium => [
        sample[1],
        sample[0],
        sample[2],
      ];

  /// The Full Leaderboard screen's data: top 10 + the current user's own
  /// rank — a separate (longer, full-name) list from [sample], matching
  /// the prototype's `view-full-leaderboard` 1:1.
  static const List<LeaderboardEntry> sampleFull = [
    LeaderboardEntry(rank: 1, name: 'Aziz K.', initials: 'AZ', xp: 4820, avatarColor: AvatarColorOption.coral),
    LeaderboardEntry(rank: 2, name: 'Malika Yusupova', initials: 'MR', xp: 4510, avatarColor: AvatarColorOption.teal),
    LeaderboardEntry(rank: 3, name: 'Shohruh Toshpulatov', initials: 'SH', xp: 4290, avatarColor: AvatarColorOption.terra),
    LeaderboardEntry(rank: 4, name: 'Dilnoza Rustamova', initials: 'DI', xp: 3980, avatarColor: AvatarColorOption.teal),
    LeaderboardEntry(rank: 5, name: 'Bekzod Xolmatov', initials: 'BX', xp: 3840, avatarColor: AvatarColorOption.terra),
    LeaderboardEntry(rank: 6, name: 'Nilufar Yoqubova', initials: 'NY', xp: 3710, avatarColor: AvatarColorOption.pink),
    LeaderboardEntry(rank: 7, name: 'Javlon Mirzayev', initials: 'JM', xp: 3540, avatarColor: AvatarColorOption.blue),
    LeaderboardEntry(rank: 8, name: 'Kamola Tursunova', initials: 'KT', xp: 3410, avatarColor: AvatarColorOption.coral),
    LeaderboardEntry(rank: 9, name: 'Otabek Rahimov', initials: 'OR', xp: 3260, avatarColor: AvatarColorOption.teal),
    LeaderboardEntry(rank: 10, name: 'Sevinch Aliyeva', initials: 'SA', xp: 3105, avatarColor: AvatarColorOption.terra),
    LeaderboardEntry(
      rank: 312,
      name: AppStrings.currentUserName,
      initials: 'AZ',
      xp: 2140,
      avatarColor: AvatarColorOption.coral,
      isCurrentUser: true,
    ),
  ];
}
