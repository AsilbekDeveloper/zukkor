import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../data/repositories/lobby_repository_impl.dart';
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
/// watchable state. [connect] must be called once (e.g. from Home) — a
/// dropped connection (idle-timeout close, brief network loss, ...) is
/// retried automatically every few seconds until it comes back (matches
/// [DuelController]'s same behavior).
class LobbyController extends Notifier<LobbyState> {
  bool _subscribed = false;
  bool _everConnected = false;
  Timer? _reconnectTimer;

  @override
  LobbyState build() => const LobbyState();

  Future<void> connect() async {
    final LobbyRepository repository = ref.read(lobbyRepositoryProvider);
    if (!_subscribed) {
      _subscribed = true;
      ref.onDispose(() => _reconnectTimer?.cancel());
      repository.connectionStatus.listen((connected) {
        state = state.copyWith(isConnected: connected);
        if (connected) {
          _everConnected = true;
          _reconnectTimer?.cancel();
        } else if (_everConnected) {
          _scheduleReconnect();
        }
      });
      repository.roomUpdates.listen(
        (room) => state = state.copyWith(room: () => room, joinError: () => null),
      );
      repository.joinErrors.listen((reason) => state = state.copyWith(joinError: () => reason));
      repository.roomClosed.listen(_handleRoomClosed);
      repository.gameStarted.listen(_handleGameStarted);
      repository.gameQuestion.listen(_handleGameQuestion);
      repository.gameQuestionResult.listen(_handleGameQuestionResult);
      repository.waitingForOthers.listen(_handleWaitingForOthers);
      repository.gameFinished.listen(_handleGameFinished);
    }
    await repository.connect();
  }

  /// A single delayed retry per disconnect — if it also fails, the next
  /// `connectionStatus` "false" event schedules another one, so this
  /// naturally keeps retrying every few seconds while offline without
  /// hammering the server in a tight loop.
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      ref.read(lobbyRepositoryProvider).connect();
    });
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
  void startGame(int categoryId, {int? questionCount}) {
    final LobbyRoomState? room = state.room;
    if (room == null) return;
    ref.read(lobbyRepositoryProvider).startGame(
          roomId: room.roomId,
          categoryId: categoryId,
          questionCount: questionCount,
        );
  }

  void _handleGameStarted(LobbyGameStartedInfo info) {
    state = state.copyWith(
      game: () => LobbyGameState(
        roomId: info.roomId,
        category: info.category,
        totalQuestions: info.totalQuestions,
      ),
    );
    unawaited(ref.read(analyticsServiceProvider).logGameStart(mode: 'lobby', categoryId: info.category.id));
  }

  void _handleGameQuestion(LobbyQuestionEvent event) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != event.roomId) return;
    state = state.copyWith(
      game: () => game.copyWith(
        questionIndex: event.questionIndex,
        question: () => event.question,
        hasAnswered: false,
        lastResult: () => null,
      ),
    );
  }

  void _handleGameQuestionResult(LobbyQuestionResult result) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != result.roomId) return;
    state = state.copyWith(game: () => game.copyWith(lastResult: () => result));
  }

  void _handleWaitingForOthers(String roomId) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != roomId) return;
    state = state.copyWith(game: () => game.copyWith(waitingForOthers: true));
  }

  void _handleGameFinished(LobbyFinalResult result) {
    final LobbyGameState? game = state.game;
    if (game == null || game.roomId != result.roomId) return;
    state = state.copyWith(game: () => game.copyWith(finalResult: () => result));
    // This device's own XP/history just changed server-side — drop the
    // cached copies so History/Home/Profile fetch fresh next visit.
    ref.invalidate(historyControllerProvider);
    ref.invalidate(myStatsControllerProvider);
    unawaited(ref.read(analyticsServiceProvider).logGameComplete(
          mode: 'lobby',
          categoryId: game.category.id,
          xpEarned: result.xpEarned,
          ballEarned: result.ballEarned,
        ));
  }

  /// Locks in an answer for the current question (or `null` on timeout).
  void submitAnswer(int? selectedOption) {
    final LobbyGameState? game = state.game;
    if (game == null || game.hasAnswered) return;
    final int correctOption = game.question!.correctOption;
    final LobbyQuestionResult localResult = LobbyQuestionResult(
      roomId: game.roomId,
      questionIndex: game.questionIndex,
      correctOption: correctOption,
      yourSelectedOption: selectedOption,
      yourCorrect: selectedOption == correctOption,
    );
    state = state.copyWith(
      game: () => game.copyWith(hasAnswered: true, lastResult: () => localResult),
    );
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
