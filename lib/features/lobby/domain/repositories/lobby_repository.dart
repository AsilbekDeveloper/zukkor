import '../entities/lobby_answer_progress.dart';
import '../entities/lobby_final_result.dart';
import '../entities/lobby_game_started_info.dart';
import '../entities/lobby_join_error.dart';
import '../entities/lobby_question_event.dart';
import '../entities/lobby_question_result.dart';
import '../entities/lobby_room_state.dart';

abstract interface class LobbyRepository {
  Stream<bool> get connectionStatus;

  /// A full roster snapshot — pushed right after this client creates or
  /// joins a room, and again whenever the roster changes.
  Stream<LobbyRoomState> get roomUpdates;

  /// Emitted only to a client whose `lobby_join` attempt failed.
  Stream<LobbyJoinErrorReason> get joinErrors;

  /// Emitted (with the closed room's id) when the host leaves and the
  /// room dissolves for everyone still in it.
  Stream<String> get roomClosed;

  Stream<LobbyGameStartedInfo> get gameStarted;
  Stream<LobbyQuestionEvent> get gameQuestion;
  Stream<LobbyAnswerProgress> get answerProgress;
  Stream<LobbyQuestionResult> get gameQuestionResult;
  Stream<LobbyFinalResult> get gameFinished;

  Future<void> connect();
  void disconnect();
  void createRoom();
  void joinRoom(String roomCode);
  void leaveRoom(String roomId);
  void startGame({required String roomId, required int categoryId});
  void submitAnswer({required String roomId, required int questionIndex, required int? selectedOption});
}
