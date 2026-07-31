import '../../../quiz/domain/entities/category.dart';
import '../../domain/entities/lobby_final_result.dart';
import '../../domain/entities/lobby_question.dart';
import '../../domain/entities/lobby_question_result.dart';

/// The live state of an in-progress (or just-finished) room game —
/// populated once `lobby_game_started` arrives, cleared once the player
/// leaves the result screen.
class LobbyGameState {
  const LobbyGameState({
    required this.roomId,
    required this.category,
    required this.totalQuestions,
    this.questionIndex = -1,
    this.question,
    this.hasAnswered = false,
    this.waitingForOthers = false,
    this.lastResult,
    this.finalResult,
  });

  final String roomId;
  final Category category;
  final int totalQuestions;
  final int questionIndex;
  final LobbyQuestion? question;
  final bool hasAnswered;

  /// True once this player has answered every question but at least one
  /// other room member hasn't finished yet — the result screen can't
  /// show until [finalResult] arrives, so this drives a "waiting" state
  /// in between. Each player answers at their own pace now, so there's
  /// no meaningful "X/N answered this question" count to show anymore.
  final bool waitingForOthers;

  /// The reveal for the question that was just answered — cleared (via
  /// `lastResult: () => null`) whenever a new question arrives.
  final LobbyQuestionResult? lastResult;
  final LobbyFinalResult? finalResult;

  LobbyGameState copyWith({
    int? questionIndex,
    LobbyQuestion? Function()? question,
    bool? hasAnswered,
    bool? waitingForOthers,
    LobbyQuestionResult? Function()? lastResult,
    LobbyFinalResult? Function()? finalResult,
  }) =>
      LobbyGameState(
        roomId: roomId,
        category: category,
        totalQuestions: totalQuestions,
        questionIndex: questionIndex ?? this.questionIndex,
        question: question != null ? question() : this.question,
        hasAnswered: hasAnswered ?? this.hasAnswered,
        waitingForOthers: waitingForOthers ?? this.waitingForOthers,
        lastResult: lastResult != null ? lastResult() : this.lastResult,
        finalResult: finalResult != null ? finalResult() : this.finalResult,
      );
}
