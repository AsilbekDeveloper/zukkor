import '../../../../core/models/avatar_color_option.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/friend.dart';

/// A single friend row — mirrors the prototype's `.friend-row` data
/// (index4.html `view-friends`). Built from the real `GET /friends`
/// entities via [FriendEntry.fromEntity]. [id] is the backend user id —
/// null only for [DuelInviteScreen]'s still-mock demo invite, which
/// isn't a real user.
class FriendEntry {
  const FriendEntry({
    required this.name,
    required this.username,
    required this.initials,
    required this.avatarColor,
    this.avatarImagePath,
    this.id,
  });

  factory FriendEntry.fromEntity(Friend entity) => FriendEntry(
        id: entity.id,
        name: _displayName(
          firstName: entity.firstName,
          lastName: entity.lastName,
          username: entity.username,
        ),
        username: entity.username,
        initials: _initials(firstName: entity.firstName, lastName: entity.lastName),
        avatarColor: AvatarColorOption.fromApiValue(entity.avatarColor),
        avatarImagePath: entity.avatarImagePath,
      );

  final String? id;
  final String name;
  final String? username;
  final String initials;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;

  /// `'@username'`, or null when the backend has no username yet (earned
  /// this friendship before ever completing onboarding).
  String? get handle => username != null ? '@$username' : null;

  static String _displayName({required String? firstName, required String? lastName, required String? username}) {
    final String name =
        [firstName, lastName].where((part) => part != null && part.isNotEmpty).join(' ');
    if (name.isNotEmpty) return name;
    if (username != null && username.isNotEmpty) return username;
    return t.leaderboard.anonymousPlayer;
  }

  static String _initials({required String? firstName, required String? lastName}) {
    final String first = (firstName?.isNotEmpty ?? false) ? firstName![0] : '';
    final String last = (lastName?.isNotEmpty ?? false) ? lastName![0] : '';
    final String combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }
}
