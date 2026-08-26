import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../data/repositories/duel_repository_impl.dart';
import '../../domain/entities/duel_final_result.dart';
import '../../domain/entities/duel_invite.dart';
import '../../domain/entities/duel_invite_outcome.dart';
import '../../domain/entities/duel_opponent_progress_event.dart';
import '../../domain/entities/duel_question_event.dart';
import '../../domain/entities/duel_question_result.dart';
import '../../domain/entities/duel_started_info.dart';
import '../../domain/repositories/duel_repository.dart';
import '../models/duel_game_state.dart';

enum OutgoingDuelStatus { idle, waiting, accepted, declined, expired, failed }

class DuelState {
  const DuelState({
    this.isConnected = false,
    this.incomingInvite,
    this.outgoingStatus = OutgoingDuelStatus.idle,
    this.outgoingErrorMessage,
    this.game,
  });

  final bool isConnected;

  /// A challenge someone just sent to the current user — the UI (Home)
  /// pushes [DuelInviteScreen] with this and then calls [DuelController.
  /// clearIncoming] once it's been shown, so it doesn't reopen itself.
  final DuelInvite? incomingInvite;

  /// The status of the invite THIS device most recently sent (Duel
  /// Waiting reads this to know when to move on).
  final OutgoingDuelStatus outgoingStatus;

  /// The server's own reason text, set alongside [OutgoingDuelStatus.
  /// failed] — e.g. the other person is no longer a friend, or the
  /// category was deactivated in the meantime.
  final String? outgoingErrorMessage;

  /// The live in-progress (or just-finished) duel game, once `duel_
  /// started` has arrived for either side of an accepted invite.
  final DuelGameState? game;

  DuelState copyWith({
    bool? isConnected,
    DuelInvite? Function()? incomingInvite,
    OutgoingDuelStatus? outgoingStatus,
    String? Function()? outgoingErrorMessage,
    DuelGameState? Function()? game,
  }) =>
      DuelState(
        isConnected: isConnected ?? this.isConnected,
        incomingInvite: incomingInvite != null ? incomingInvite() : this.incomingInvite,
        outgoingStatus: outgoingStatus ?? this.outgoingStatus,
        outgoingErrorMessage: outgoingErrorMessage != null ? outgoingErrorMessage() : this.outgoingErrorMessage,
        game: game != null ? game() : this.game,
      );
}

/// Owns the duel WebSocket's lifecycle and turns its event streams into
/// watchable state. [connect] must be called once (e.g. from Home) — a
/// dropped connection (idle-timeout close, brief network loss, ...) is
/// retried automatically every few seconds until it comes back.
class DuelController extends Notifier<DuelState> {
  bool _subscribed = false;
  bool _everConnected = false;
  Timer? _reconnectTimer;
  String? _currentOutgoingClientId;
  static int _clientInviteIdCounter = 0;

  @override
  DuelState build() => const DuelState();

  Future<void> connect() async {
    final DuelRepository repository = ref.read(duelRepositoryProvider);
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
      repository.incomingInvites.listen((invite) => state = state.copyWith(incomingInvite: () => invite));
      repository.outgoingInviteOutcomes.listen(_handleOutgoingOutcome);
      repository.duelStarted.listen(_handleDuelStarted);
      repository.duelQuestion.listen(_handleDuelQuestion);
      repository.opponentProgress.listen(_handleOpponentProgress);
      repository.duelQuestionResult.listen(_handleDuelQuestionResult);
      repository.waitingForOpponent.listen(_handleWaitingForOpponent);
      repository.duelFinished.listen(_handleDuelFinished);
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
      ref.read(duelRepositoryProvider).connect();
    });
  }

  void _handleOutgoingOutcome(DuelInviteOutcome outcome) {
    if (outcome.clientInviteId != _currentOutgoingClientId) return;
    state = state.copyWith(
      outgoingStatus: switch (outcome.status) {
        DuelInviteOutcomeStatus.accepted => OutgoingDuelStatus.accepted,
        DuelInviteOutcomeStatus.declined => OutgoingDuelStatus.declined,
        DuelInviteOutcomeStatus.expired => OutgoingDuelStatus.expired,
        DuelInviteOutcomeStatus.failed => OutgoingDuelStatus.failed,
      },
      outgoingErrorMessage: () => outcome.message,
    );
  }

  void sendInvite({required String toUserId, required int categoryId, int? questionCount}) {
    _clientInviteIdCounter++;
    final String clientInviteId = '${DateTime.now().microsecondsSinceEpoch}-$_clientInviteIdCounter';
    _currentOutgoingClientId = clientInviteId;
    state = state.copyWith(outgoingStatus: OutgoingDuelStatus.waiting, outgoingErrorMessage: () => null);
    ref.read(duelRepositoryProvider).sendInvite(
          toUserId: toUserId,
          categoryId: categoryId,
          clientInviteId: clientInviteId,
          questionCount: questionCount,
        );
  }

  /// Called once Duel Waiting has reacted to a terminal [outgoingStatus]
  /// (accepted/declined/expired/failed) so a later invite starts clean.
  void resetOutgoing() {
    _currentOutgoingClientId = null;
    state = state.copyWith(outgoingStatus: OutgoingDuelStatus.idle, outgoingErrorMessage: () => null);
  }

  /// [inviteId] comes from the invite [DuelInviteScreen] was actually
  /// given (its widget parameter), not from [DuelState.incomingInvite] —
  /// that field may be stale or empty if the screen was reached any way
  /// other than the live Home listener (e.g. a direct deep link, or in
  /// tests), and responding should still work regardless.
  void respondToInvite({required String inviteId, required bool accept}) {
    ref.read(duelRepositoryProvider).respondToInvite(inviteId: inviteId, accept: accept);
    if (state.incomingInvite?.id == inviteId) {
      state = state.copyWith(incomingInvite: () => null);
    }
  }

  /// Called once Home has pushed [DuelInviteScreen] for the current
  /// [DuelState.incomingInvite], so it doesn't push it again on rebuild.
  void clearIncoming() {
    state = state.copyWith(incomingInvite: () => null);
  }

  void _handleDuelStarted(DuelStartedInfo info) {
    state = state.copyWith(
      game: () => DuelGameState(
        duelId: info.duelId,
        category: info.category,
        opponent: info.opponent,
        totalQuestions: info.totalQuestions,
      ),
    );
    unawaited(ref.read(analyticsServiceProvider).logGameStart(mode: 'duel', categoryId: info.category.id));
  }

  void _handleDuelQuestion(DuelQuestionEvent event) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != event.duelId) return;
    state = state.copyWith(
      game: () => game.copyWith(
        questionIndex: event.questionIndex,
        question: () => event.question,
        hasAnswered: false,
        lastResult: () => null,
      ),
    );
  }

  void _handleOpponentProgress(DuelOpponentProgressEvent event) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != event.duelId) return;
    state = state.copyWith(game: () => game.copyWith(opponentQuestionIndex: () => event.opponentQuestionIndex));
  }

  void _handleDuelQuestionResult(DuelQuestionResult result) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != result.duelId) return;
    state = state.copyWith(game: () => game.copyWith(lastResult: () => result));
  }

  void _handleWaitingForOpponent(String duelId) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != duelId) return;
    state = state.copyWith(game: () => game.copyWith(waitingForOpponent: true));
  }

  void _handleDuelFinished(DuelFinalResult result) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != result.duelId) return;
    state = state.copyWith(game: () => game.copyWith(finalResult: () => result));
    // This device's own XP/history just changed server-side — drop the
    // cached copies so History/Home/Profile fetch fresh next visit.
    ref.invalidate(historyControllerProvider);
    ref.invalidate(myStatsControllerProvider);
    unawaited(ref.read(analyticsServiceProvider).logGameComplete(
          mode: 'duel',
          categoryId: game.category.id,
          xpEarned: result.xpEarned,
          ballEarned: result.ballEarned,
        ));
  }

  /// Locks in an answer for the current question (or `null` on timeout).
  void submitAnswer(int? selectedOption) {
    final DuelGameState? game = state.game;
    if (game == null || game.hasAnswered) return;
    final int correctOption = game.question!.correctOption;
    final DuelQuestionResult localResult = DuelQuestionResult(
      duelId: game.duelId,
      questionIndex: game.questionIndex,
      correctOption: correctOption,
      yourSelectedOption: selectedOption,
      yourCorrect: selectedOption == correctOption,
    );
    state = state.copyWith(
      game: () => game.copyWith(hasAnswered: true, lastResult: () => localResult),
    );
    ref.read(duelRepositoryProvider).submitAnswer(
          duelId: game.duelId,
          questionIndex: game.questionIndex,
          selectedOption: selectedOption,
        );
  }

  /// Called once the duel result screen is left, so a later duel starts
  /// clean.
  void clearGame() {
    state = state.copyWith(game: () => null);
  }
}

final NotifierProvider<DuelController, DuelState> duelControllerProvider =
    NotifierProvider<DuelController, DuelState>(DuelController.new);
