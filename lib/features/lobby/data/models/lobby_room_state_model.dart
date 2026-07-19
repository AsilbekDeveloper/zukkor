import '../../domain/entities/lobby_room_state.dart';
import 'lobby_participant_model.dart';

class LobbyRoomStateModel {
  const LobbyRoomStateModel({
    required this.roomId,
    required this.roomCode,
    required this.youParticipantId,
    required this.participants,
  });

  factory LobbyRoomStateModel.fromJson(Map<String, dynamic> json) => LobbyRoomStateModel(
        roomId: json['room_id'] as String,
        roomCode: json['room_code'] as String,
        youParticipantId: json['you_participant_id'] as String,
        participants: (json['participants'] as List<dynamic>)
            .map((entry) => LobbyParticipantModel.fromJson(entry as Map<String, dynamic>))
            .toList(),
      );

  final String roomId;
  final String roomCode;
  final String youParticipantId;
  final List<LobbyParticipantModel> participants;

  LobbyRoomState toEntity() => LobbyRoomState(
        roomId: roomId,
        roomCode: roomCode,
        youParticipantId: youParticipantId,
        participants: participants.map((p) => p.toEntity()).toList(),
      );
}
