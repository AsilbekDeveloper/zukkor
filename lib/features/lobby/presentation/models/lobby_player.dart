import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/avatar_color_option.dart';

/// A player row shown in the Lobby's player list — mirrors the
/// prototype's `.player-row` (host gets a crown badge next to the name).
class LobbyPlayer {
  const LobbyPlayer({
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isHost = false,
  });

  final String name;
  final String initials;
  final AvatarColorOption avatarColor;
  final bool isHost;

  /// The room's fixed cast — mirrors the prototype's mock lobby exactly.
  static const List<LobbyPlayer> sampleHostAndGuests = [
    LobbyPlayer(name: 'Aziz', initials: 'AZ', avatarColor: AvatarColorOption.coral, isHost: true),
    LobbyPlayer(name: 'Malika', initials: 'MR', avatarColor: AvatarColorOption.teal),
    LobbyPlayer(name: 'Shohruh', initials: 'SH', avatarColor: AvatarColorOption.terra),
    LobbyPlayer(name: 'Dilnoza', initials: 'DI', avatarColor: AvatarColorOption.pink),
  ];

  /// The current device's own row, appended only when joining as a
  /// guest — mirrors the prototype's dynamically-inserted "Siz" row.
  static const LobbyPlayer you = LobbyPlayer(
    name: AppStrings.currentUserName,
    initials: 'SZ',
    avatarColor: AvatarColorOption.blue,
  );

  static const int maxPlayers = 20;
}
