import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/duel_repository_impl.dart';
import '../../domain/entities/duel_final_result.dart';
import '../../domain/entities/duel_invite.dart';
import '../../domain/entities/duel_invite_outcome.dart';
import '../../domain/entities/duel_opponent_answered_event.dart';
import '../../domain/entities/duel_question_event.dart';
import '../../domain/entities/duel_question_result.dart';
import '../../domain/entities/duel_started_info.dart';
import '../../domain/repositories/duel_repository.dart';
import '../models/duel_game_state.dart';

enum OutgoingDuelStatus { idle, waiting, accepted, declined, expired }

class DuelState {
  const DuelState({
    this.isConnected = false,
    this.incomingInvite,
    this.outgoingStatus = OutgoingDuelStatus.idle,
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

  /// The live in-progress (or just-finished) duel game, once `duel_
  /// started` has arrived for either side of an accepted invite.
  final DuelGameState? game;

  DuelState copyWith({
    bool? isConnected,
    DuelInvite? Function()? incomingInvite,
    OutgoingDuelStatus? outgoingStatus,
    DuelGameState? Function()? game,
  }) =>
      DuelState(
        isConnected: isConnected ?? this.isConnected,
        incomingInvite: incomingInvite != null ? incomingInvite() : this.incomingInvite,
        outgoingStatus: outgoingStatus ?? this.outgoingStatus,
        game: game != null ? game() : this.game,
      );
}

/// Owns the duel WebSocket's lifecycle and turns its event streams into
/// watchable state. [connect] must be called once (e.g. from Home) —
/// there's no automatic reconnect-on-app-resume yet, a known gap.
class DuelController extends Notifier<DuelState> {
  bool _subscribed = false;
  String? _currentOutgoingClientId;
  static int _clientInviteIdCounter = 0;

  @override
  DuelState build() => const DuelState();

  Future<void> connect() async {
    final DuelRepository repository = ref.read(duelRepositoryProvider);
    if (!_subscribed) {
      _subscribed = true;
      repository.connectionStatus.listen((connected) => state = state.copyWith(isConnected: connected));
      repository.incomingInvites.listen((invite) => state = state.copyWith(incomingInvite: () => invite));
      repository.outgoingInviteOutcomes.listen(_handleOutgoingOutcome);
      repository.duelStarted.listen(_handleDuelStarted);
      repository.duelQuestion.listen(_handleDuelQuestion);
      repository.opponentAnswered.listen(_handleOpponentAnswered);
      repository.duelQuestionResult.listen(_handleDuelQuestionResult);
      repository.duelFinished.listen(_handleDuelFinished);
    }
    await repository.connect();
  }

  void _handleOutgoingOutcome(DuelInviteOutcome outcome) {
    if (outcome.clientInviteId != _currentOutgoingClientId) return;
    state = state.copyWith(
      outgoingStatus: switch (outcome.status) {
        DuelInviteOutcomeStatus.accepted => OutgoingDuelStatus.accepted,
        DuelInviteOutcomeStatus.declined => OutgoingDuelStatus.declined,
        DuelInviteOutcomeStatus.expired => OutgoingDuelStatus.expired,
      },
    );
  }

  void sendInvite({required String toUserId, required int categoryId}) {
    _clientInviteIdCounter++;
    final String clientInviteId = '${DateTime.now().microsecondsSinceEpoch}-$_clientInviteIdCounter';
    _currentOutgoingClientId = clientInviteId;
    state = state.copyWith(outgoingStatus: OutgoingDuelStatus.waiting);
    ref.read(duelRepositoryProvider).sendInvite(
          toUserId: toUserId,
          categoryId: categoryId,
          clientInviteId: clientInviteId,
        );
  }

  /// Called once Duel Waiting has reacted to a terminal [outgoingStatus]
  /// (accepted/declined/expired) so a later invite starts clean.
  void resetOutgoing() {
    _currentOutgoingClientId = null;
    state = state.copyWith(outgoingStatus: OutgoingDuelStatus.idle);
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
  }

  void _handleDuelQuestion(DuelQuestionEvent event) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != event.duelId) return;
    state = state.copyWith(
      game: () => game.copyWith(
        questionIndex: event.questionIndex,
        question: () => event.question,
        hasAnswered: false,
        opponentHasAnswered: false,
        lastResult: () => null,
      ),
    );
  }

  void _handleOpponentAnswered(DuelOpponentAnsweredEvent event) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != event.duelId || game.questionIndex != event.questionIndex) return;
    state = state.copyWith(game: () => game.copyWith(opponentHasAnswered: true));
  }

  void _handleDuelQuestionResult(DuelQuestionResult result) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != result.duelId) return;
    state = state.copyWith(game: () => game.copyWith(lastResult: () => result));
  }

  void _handleDuelFinished(DuelFinalResult result) {
    final DuelGameState? game = state.game;
    if (game == null || game.duelId != result.duelId) return;
    state = state.copyWith(game: () => game.copyWith(finalResult: () => result));
  }

  /// Locks in an answer for the current question (or `null` on timeout).
  void submitAnswer(int? selectedOption) {
    final DuelGameState? game = state.game;
    if (game == null || game.hasAnswered) return;
    state = state.copyWith(game: () => game.copyWith(hasAnswered: true));
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
