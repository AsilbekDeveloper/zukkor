import '../../../../core/models/avatar_color_option.dart';

/// A single friend row — mirrors the prototype's `.friend-row` /
/// `.online-item` data (index4.html `view-friends`).
class FriendEntry {
  const FriendEntry({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    required this.statusLabel,
  });

  final String name;
  final String initials;
  final AvatarColorOption avatarColor;
  final bool isOnline;

  /// e.g. "Online", "2 hours ago", "Yesterday" — mock presence text,
  /// there's no backend yet to compute this from a real timestamp.
  final String statusLabel;

  /// The 3 friends shown in the horizontal "Online" row.
  static const List<FriendEntry> sampleOnline = [
    FriendEntry(name: 'Malika', initials: 'MR', avatarColor: AvatarColorOption.teal, isOnline: true, statusLabel: 'Online'),
    FriendEntry(name: 'Shohruh', initials: 'SH', avatarColor: AvatarColorOption.terra, isOnline: true, statusLabel: 'Online'),
    FriendEntry(name: 'Dilnoza', initials: 'DI', avatarColor: AvatarColorOption.pink, isOnline: true, statusLabel: 'Online'),
  ];

  /// The full "All friends" list. [totalFriendCount] (shown next to the
  /// section title) is intentionally larger — it mirrors the prototype's
  /// static "12" badge, standing in for friends beyond this sample page.
  static const List<FriendEntry> sampleAll = [
    FriendEntry(name: 'Malika Yusupova', initials: 'MR', avatarColor: AvatarColorOption.teal, isOnline: true, statusLabel: 'Online'),
    FriendEntry(name: 'Shohruh Toshpulatov', initials: 'SH', avatarColor: AvatarColorOption.terra, isOnline: true, statusLabel: 'Online'),
    FriendEntry(name: 'Dilnoza Rustamova', initials: 'DI', avatarColor: AvatarColorOption.pink, isOnline: true, statusLabel: 'Online'),
    FriendEntry(name: 'Bekzod Xolmatov', initials: 'BX', avatarColor: AvatarColorOption.coral, isOnline: false, statusLabel: '2 hours ago'),
    FriendEntry(name: 'Nilufar Yoqubova', initials: 'NY', avatarColor: AvatarColorOption.blue, isOnline: false, statusLabel: 'Yesterday'),
  ];

  static const int totalFriendCount = 12;

  /// Friends eligible to be challenged to a duel right now — mirrors the
  /// prototype's 1v1 Duel screen, which only lists online friends.
  static List<FriendEntry> get sampleOnlineForDuel =>
      sampleAll.where((e) => e.isOnline).toList();
}
