import 'package:flutter/widgets.dart';

import '../../../../core/models/avatar_color_option.dart';
import '../../../../i18n/strings.g.dart';

/// A player row shown in the Lobby's player list — mirrors the
/// prototype's `.player-row` (host gets a crown badge next to the name).
class LobbyPlayer {
  const LobbyPlayer({
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isHost = false,
    this.isYou = false,
  });

  final String name;
  final String initials;
  final AvatarColorOption avatarColor;
  final bool isHost;

  /// True only for [you] — drives the translated "You" display name, see
  /// [LobbyPlayerDisplayName.displayName].
  final bool isYou;

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
    name: 'You',
    initials: 'SZ',
    avatarColor: AvatarColorOption.blue,
    isYou: true,
  );

  static const int maxPlayers = 20;
}

extension LobbyPlayerDisplayName on LobbyPlayer {
  /// [name] itself stays a plain English placeholder (sample data) —
  /// [you]'s row always shows the translated "You" instead.
  String displayName(BuildContext context) => isYou ? context.t.leaderboard.you : name;
}
