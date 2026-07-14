import '../../../../core/models/avatar_color_option.dart';

/// A person you can add as a friend — mirrors what Add Friend's "search
/// by username" would return from a real user directory. Deliberately
/// separate from [FriendEntry]: these are people NOT already on your
/// friends list.
class DiscoverableUser {
  const DiscoverableUser({
    required this.name,
    required this.username,
    required this.initials,
    required this.avatarColor,
  });

  final String name;
  final String username;
  final String initials;
  final AvatarColorOption avatarColor;

  static const List<DiscoverableUser> sample = [
    DiscoverableUser(name: 'Sardor Aliyev', username: 'sardor_aliyev', initials: 'SA', avatarColor: AvatarColorOption.blue),
    DiscoverableUser(name: 'Gulnora Karimova', username: 'gulnora_k', initials: 'GK', avatarColor: AvatarColorOption.pink),
    DiscoverableUser(name: 'Jasur Yusupov', username: 'jasur_yusupov', initials: 'JY', avatarColor: AvatarColorOption.teal),
    DiscoverableUser(name: 'Madina Rashidova', username: 'madina_r', initials: 'MR', avatarColor: AvatarColorOption.terra),
    DiscoverableUser(name: 'Otabek Nazarov', username: 'otabek_n', initials: 'ON', avatarColor: AvatarColorOption.coral),
  ];
}
