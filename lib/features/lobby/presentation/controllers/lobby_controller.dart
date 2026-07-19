import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/lobby_repository_impl.dart';
import '../../domain/entities/lobby_answer_progress.dart';
import '../../domain/entities/lobby_final_result.dart';
import '../../domain/entities/lobby_game_started_info.dart';
import '../../domain/entities/lobby_join_error.dart';
import '../../domain/entities/lobby_question_event.dart';
import '../../domain/entities/lobby_question_result.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../../domain/repositories/lobby_repository.dart';
import '../models/lobby_game_state.dart';

class LobbyState {
  const LobbyState({
    this.isConnected = false,
    this.room,
    this.joinError,
    this.closed = false,
    this.game,
  });

  final bool isConnected;

  /// The current room's live roster, once created or joined — cleared
  /// (via [LobbyController.leaveRoom]) when the player leaves. Stays
  /// populated throughout gameplay too (name/avatar lookups for
  /// [game]'s standings come from here).
  final LobbyRoomState? room;

  /// Set only when this device's own `lobby_join` attempt was rejected.
  final LobbyJoinErrorReason? joinError;

  /// True right after the host has left and the room dissolved — the UI
  /// shows a message and clears it via [LobbyController.clearClosed].
  final bool closed;

  /// The live in-progress (or just-finished) room game, once
  /// `lobby_game_started` has arrived.
  final LobbyGameState? game;

  LobbyState copyWith({
    bool? isConnected,
    LobbyRoomState? Function()? room,
    LobbyJoinErrorReason? Function()? joinError,
    bool? closed,
    LobbyGameState? Function()? game,
  }) =>
      LobbyState(
        isConnected: isConnected ?? this.isConnected,
        room: room != null ? room() : this.room,
        joinError: joinError != null ? joinError() : this.joinError,
        closed: closed ?? this.closed,
        game: game != null ? game() : this.game,
      );
}

/// Owns the lobby WebSocket's lifecycle and turns its event streams into
/// watchable state. [connect] must be called once (e.g. from Home) —
/// there's no automatic reconnect-on-app-resume yet, a known gap
/// (matches [DuelController]'s same gap).
class LobbyController extends Notifier<LobbyState> {
  bool _subscribed = false;

  @override
  LobbyState build() => const LobbyState();

  Future<void> connect() async {
    final LobbyRepository repository = ref.read(lobbyRepositoryProvider);
    if (!_subscribed) {
      _subscribed = true;
      repository.connectionStatus.listen((connected) => state = state.copyWith(isConnected: connected));
      repository.roomUpdates.listen(
        (room) => state = state.copyWith(room: () => room, joinError: () => null),
      );
      repository.joinErrors.listen((reason) => state = state.copyWith(joinError: () => reason));
      repository.roomClosed.listen(_handleRoomClosed);
      repository.gameStarted.listen(_handleGameStarted);
      repository.gameQuestion.listen(_handleGameQuestion);
      repository.answerProgress.listen(_handleAnswerProgress);
      repository.gameQuestionResult.listen(_handleGameQuestionResult);
      repository.gameFinished.listen(_handleGameFinished);
    }
    await repository.connect();
  }

  void _handleRoomClosed(String roomId) {
    if (state.room?.roomId != roomId) return;
    state = state.copyWith(room: () => null, closed: true);
  }

  void createRoom() {
    state = state.copyWith(joinError: () => null);
    ref.read(lobbyRepositoryProvider).createRoom();
  }

  void joinRoom(String roomCode) {
    state = state.copyWith(joinError: () => null);
    ref.read(lobbyRepositoryProvider).joinRoom(roomCode);
  }

  void leaveRoom() {
    final LobbyRoomState? room = state.room;
    if (room != null) {
      ref.read(lobbyRepositoryProvider).leaveRoom(room.roomId);
    }
    state = state.copyWith(room: () => null);
  }

  /// Called once the UI has shown the "room closed" message, so it
  /// doesn't show it again on rebuild.
  void clearClosed() {
    state = state.copyWith(closed: false);
  }

  /// Host-only: picks a category and kicks off a synchronized game for
  /// the whole room.
  void startGame(int categoryId) {
    final LobbyRoomState? room = state.room;
    if (room == null) return;
    ref.read(lobbyRepositoryProvider).startGame(roomId: room.roomId, categoryId: categoryId);
  }

  void _handleGameStarted(LobbyGameStartedInfo info) {
    state = state.copyWith(
      game: () => LobbyGameState(
        roomId: info.roomId,
        category: info.category,
        totalQuestions: info.totalQuestions,
      ),
    );
  }

  void _handleGameQuestion(LobbyQuestionEvent event) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != event.roomId) return;
    state = state.copyWith(
      game: () => game.copyWith(
        questionIndex: event.questionIndex,
        question: () => event.question,
        hasAnswered: false,
        answeredCount: 0,
        lastResult: () => null,
      ),
    );
  }

  void _handleAnswerProgress(LobbyAnswerProgress progress) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != progress.roomId || game.questionIndex != progress.questionIndex) return;
    state = state.copyWith(game: () => game.copyWith(answeredCount: progress.answeredCount));
  }

  void _handleGameQuestionResult(LobbyQuestionResult result) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != result.roomId) return;
    state = state.copyWith(game: () => game.copyWith(lastResult: () => result));
  }

  void _handleGameFinished(LobbyFinalResult result) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != result.roomId) return;
    state = state.copyWith(game: () => game.copyWith(finalResult: () => result));
  }

  /// Locks in an answer for the current question (or `null` on timeout).
  void submitAnswer(int? selectedOption) {
    final LobbyGameState? game = state.game;
    if (game == null || game.hasAnswered) return;
    state = state.copyWith(game: () => game.copyWith(hasAnswered: true));
    ref.read(lobbyRepositoryProvider).submitAnswer(
          roomId: game.roomId,
          questionIndex: game.questionIndex,
          selectedOption: selectedOption,
        );
  }

  /// Called once the room result screen is left, so a later game starts
  /// clean.
  void clearGame() {
    state = state.copyWith(game: () => null);
  }
}

final NotifierProvider<LobbyController, LobbyState> lobbyControllerProvider =
    NotifierProvider<LobbyController, LobbyState>(LobbyController.new);
