import '../../domain/entities/lobby_final_result.dart';
import '../../domain/entities/lobby_room_state.dart';

/// [LobbyResultScreen]'s route `extra` — an immutable snapshot of the
/// room roster + final standings at the moment the game finished.
///
/// Deliberately NOT read live from [LobbyController]'s state: that state
/// gets cleared (`clearGame()`) once the result screen mounts, and a
/// widget that kept `ref.watch`-ing it would flash back to a loading
/// spinner the instant that happened.
class LobbyResultArgs {
  const LobbyResultArgs({required this.room, required this.result});

  final LobbyRoomState room;
  final LobbyFinalResult result;
}
