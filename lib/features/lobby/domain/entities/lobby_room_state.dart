import 'lobby_participant.dart';

/// A full roster snapshot for one room — `lobby_room_update` pushes this
/// to a client right after they create/join, and again every time the
/// roster changes (someone else joins or leaves).
class LobbyRoomState {
  const LobbyRoomState({
    required this.roomId,
    required this.roomCode,
    required this.youParticipantId,
    required this.participants,
  });

  final String roomId;
  final String roomCode;

  /// Which entry in [participants] is the recipient themselves — the
  /// server computes this per-recipient so the client never has to
  /// compare against its own user id.
  final String youParticipantId;
  final List<LobbyParticipant> participants;
}
