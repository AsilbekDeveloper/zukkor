import '../../../../core/models/avatar_color_option.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/friend_request.dart';

/// One row on the Friend Requests screen — built from a real
/// `GET /friends/requests/incoming` entity via [FriendRequestEntry.fromEntity].
class FriendRequestEntry {
  const FriendRequestEntry({
    required this.id,
    required this.name,
    required this.username,
    required this.initials,
    required this.avatarColor,
    this.avatarImagePath,
  });

  factory FriendRequestEntry.fromEntity(FriendRequest entity) => FriendRequestEntry(
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

  final String id;
  final String name;
  final String? username;
  final String initials;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;

  /// `'@username'`, or null when the backend has no username yet.
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
