import '../../../quiz/domain/entities/category.dart';
import '../../domain/entities/duel_final_result.dart';
import '../../domain/entities/duel_participant.dart';
import '../../domain/entities/duel_question.dart';
import '../../domain/entities/duel_question_result.dart';

/// The live state of an in-progress (or just-finished) duel game —
/// populated once `duel_started` arrives, cleared once the player
/// leaves the result screen.
class DuelGameState {
  const DuelGameState({
    required this.duelId,
    required this.category,
    required this.opponent,
    required this.totalQuestions,
    this.questionIndex = -1,
    this.question,
    this.hasAnswered = false,
    this.opponentQuestionIndex,
    this.waitingForOpponent = false,
    this.lastResult,
    this.finalResult,
    this.opponentDisconnected = false,
  });

  final String duelId;
  final Category category;
  final DuelParticipant opponent;
  final int totalQuestions;
  final int questionIndex;
  final DuelQuestion? question;
  final bool hasAnswered;

  /// The opponent's own progress, purely cosmetic (each player answers
  /// at their own pace, this doesn't gate anything) — `null` until the
  /// first `duel_opponent_progress` arrives.
  final int? opponentQuestionIndex;

  /// True once this player has answered every question but the
  /// opponent hasn't finished yet — the result screen can't show until
  /// [finalResult] arrives, so this drives a "waiting" state in between.
  final bool waitingForOpponent;

  /// The reveal for the question that was just answered — cleared (via
  /// `lastResult: () => null`) whenever a new question arrives.
  final DuelQuestionResult? lastResult;
  final DuelFinalResult? finalResult;

  /// True from a `duel_opponent_disconnected` event until either
  /// `duel_opponent_reconnected` arrives (cleared) or the duel is
  /// cancelled outright once their grace window expires - drives a
  /// "raqibning aloqasi uzilgan" banner instead of the game just
  /// looking stuck with no explanation (2026-09-13, user request).
  final bool opponentDisconnected;

  DuelGameState copyWith({
    int? questionIndex,
    DuelQuestion? Function()? question,
    bool? hasAnswered,
    int? Function()? opponentQuestionIndex,
    bool? waitingForOpponent,
    DuelQuestionResult? Function()? lastResult,
    DuelFinalResult? Function()? finalResult,
    bool? opponentDisconnected,
  }) => DuelGameState(
    duelId: duelId,
    category: category,
    opponent: opponent,
    totalQuestions: totalQuestions,
    questionIndex: questionIndex ?? this.questionIndex,
    question: question != null ? question() : this.question,
    hasAnswered: hasAnswered ?? this.hasAnswered,
    opponentQuestionIndex: opponentQuestionIndex != null
        ? opponentQuestionIndex()
        : this.opponentQuestionIndex,
    waitingForOpponent: waitingForOpponent ?? this.waitingForOpponent,
    lastResult: lastResult != null ? lastResult() : this.lastResult,
    finalResult: finalResult != null ? finalResult() : this.finalResult,
    opponentDisconnected: opponentDisconnected ?? this.opponentDisconnected,
  );
}
