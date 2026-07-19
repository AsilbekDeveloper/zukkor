import 'package:flutter/widgets.dart';

import '../../../../core/models/avatar_color_option.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/lobby_participant.dart';

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

  /// True only for [you] (or the roster entry matching [LobbyRoomState.
  /// youParticipantId]) — drives the translated "You" display name, see
  /// [LobbyPlayerDisplayName.displayName].
  final bool isYou;

  /// Builds a row from a real roster entry — [isYou] comes from
  /// comparing the entry's id against `LobbyRoomState.youParticipantId`
  /// (the server tells each recipient which entry is their own).
  factory LobbyPlayer.fromEntity(LobbyParticipant entity, {required bool isYou}) {
    final String name = [entity.firstName, entity.lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');
    final String first = (entity.firstName?.isNotEmpty ?? false) ? entity.firstName![0] : '';
    final String last = (entity.lastName?.isNotEmpty ?? false) ? entity.lastName![0] : '';
    final String initials = '$first$last'.toUpperCase();
    return LobbyPlayer(
      name: name.isNotEmpty
          ? name
          : ((entity.username?.isNotEmpty ?? false) ? entity.username! : t.leaderboard.anonymousPlayer),
      initials: initials.isNotEmpty ? initials : '?',
      avatarColor: AvatarColorOption.fromApiValue(entity.avatarColor),
      isHost: entity.isHost,
      isYou: isYou,
    );
  }

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
