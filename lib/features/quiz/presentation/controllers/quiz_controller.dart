import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/answer_result.dart';
import '../../domain/entities/quiz_question_data.dart';
import '../models/quiz_category.dart';
import '../models/quiz_result.dart';

/// The question-answer loop's own state — owned here (not [QuizScreen])
/// so the session logic matches the pattern used by [DuelController] /
/// [LobbyController]: the screen only renders this and drives navigation
/// off it, it never mutates session fields itself.
class QuizSessionState {
  const QuizSessionState({
    this.starting = true,
    this.sessionId,
    this.currentQuestion,
    this.answered = false,
    this.selectedIndex,
    this.lastCorrectIndex,
    this.totalBall = 0,
    this.pendingResult,
    this.result,
  });

  final bool starting;
  final String? sessionId;
  final QuizQuestionData? currentQuestion;
  final bool answered;
  final int? selectedIndex;
  final int? lastCorrectIndex;
  final int totalBall;

  /// The network's answer already came back, but [QuizScreen]'s own
  /// minimum "let the user see the reveal" pause hasn't elapsed yet —
  /// [QuizController.commitPendingResult] applies it once both are done,
  /// so the reveal is never cut short just because the network was fast.
  final AnswerResult? pendingResult;

  /// Set once the session's last question has been committed — the
  /// screen reacts to this to navigate to Ball Reveal.
  final QuizResult? result;

  QuizSessionState copyWith({
    bool? starting,
    String? Function()? sessionId,
    QuizQuestionData? Function()? currentQuestion,
    bool? answered,
    int? Function()? selectedIndex,
    int? Function()? lastCorrectIndex,
    int? totalBall,
    AnswerResult? Function()? pendingResult,
    QuizResult? Function()? result,
  }) => QuizSessionState(
    starting: starting ?? this.starting,
    sessionId: sessionId != null ? sessionId() : this.sessionId,
    currentQuestion: currentQuestion != null
        ? currentQuestion()
        : this.currentQuestion,
    answered: answered ?? this.answered,
    selectedIndex: selectedIndex != null ? selectedIndex() : this.selectedIndex,
    lastCorrectIndex: lastCorrectIndex != null
        ? lastCorrectIndex()
        : this.lastCorrectIndex,
    totalBall: totalBall ?? this.totalBall,
    pendingResult: pendingResult != null ? pendingResult() : this.pendingResult,
    result: result != null ? result() : this.result,
  );
}

/// Owns the solo quiz session loop — starting it, submitting each answer,
/// and the server-authoritative scoring/summary that comes back.
/// Navigation, the countdown [AnimationController] and the leave-confirm
/// dialog stay in [QuizScreen] (those are genuinely view concerns); every
/// exception here propagates to the caller unchanged, same as before, so
/// the screen's own try/catch still drives the error snackbar + go-home.
class QuizController extends Notifier<QuizSessionState> {
  @override
  QuizSessionState build() => const QuizSessionState();

  Future<void> startSession({
    required QuizCategory category,
    required int questionCount,
  }) async {
    // A brand-new session always starts from a clean slate — this
    // provider isn't autoDispose, so a second quiz played in the same
    // app session must not inherit the previous one's leftovers.
    state = const QuizSessionState();
    final result = await ref
        .read(startQuizUseCaseProvider)
        .call(categoryId: category.id, questionCount: questionCount);
    if (!ref.mounted) return;
    state = state.copyWith(
      starting: false,
      sessionId: () => result.sessionId,
      currentQuestion: () => result.question,
    );
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logGameStart(mode: 'solo', categoryId: category.id),
    );
  }

  /// Locks in [selectedOption] (`null` on timeout) and submits it over
  /// the network. This only stores the raw [AnswerResult] once it comes
  /// back — [commitPendingResult] is what actually applies it (scoring,
  /// advancing to the next question or finishing the session). The
  /// caller is expected to run this concurrently with its own minimum
  /// "let the user see the reveal" pause, then call [commitPendingResult]
  /// once both are done — that pacing is a view-timing concern, not
  /// session state, so it stays in [QuizScreen].
  Future<void> submitAnswer({required int? selectedOption}) async {
    final QuizQuestionData question = state.currentQuestion!;
    final int correctIndex = question.correctOptionIndex;
    state = state.copyWith(
      answered: true,
      selectedIndex: () => selectedOption,
      lastCorrectIndex: () => correctIndex,
    );
    final result = await ref
        .read(submitAnswerUseCaseProvider)
        .call(
          sessionId: state.sessionId!,
          sessionQuestionId: question.sessionQuestionId,
          selectedOption: selectedOption,
        );
    if (!ref.mounted) return;
    state = state.copyWith(pendingResult: () => result);
  }

  /// Applies the [AnswerResult] that [submitAnswer] already fetched —
  /// advances to the next question, or finishes the session.
  void commitPendingResult(QuizCategory category) {
    final AnswerResult? result = state.pendingResult;
    if (result == null) return;
    final int newTotalBall = state.totalBall + result.ballEarned;

    if (result.isSessionComplete) {
      final summary = result.summary!;
      final QuizResult quizResult = QuizResult(
        category: category,
        correctCount: summary.correctCount,
        totalCount: summary.totalQuestions,
        xpEarned: summary.xpEarned,
        totalBall: summary.totalBall,
        breakdown: summary.breakdown,
      );
      state = state.copyWith(
        totalBall: newTotalBall,
        result: () => quizResult,
        pendingResult: () => null,
      );
      _onSessionComplete(
        category: category,
        xpEarned: summary.xpEarned,
        ballEarned: summary.totalBall,
      );
      return;
    }

    state = state.copyWith(
      totalBall: newTotalBall,
      currentQuestion: () => result.nextQuestion,
      answered: false,
      selectedIndex: () => null,
      lastCorrectIndex: () => null,
      pendingResult: () => null,
    );
  }

  void _onSessionComplete({
    required QuizCategory category,
    required int xpEarned,
    required int ballEarned,
  }) {
    // This session's own XP/history just changed server-side — drop the
    // cached copy so History fetches fresh next time it's visited (a
    // regular pushed screen, so it always remounts). Home/Profile are
    // different: they live in the persistent bottom-nav shell and never
    // remount, so merely invalidating would leave them stuck showing
    // 0/0/0 forever (2026-09-06, reported from a live device — "stats go
    // to 0 after finishing any quiz and returning home") — reload it
    // immediately here instead of hoping some screen's initState notices
    // the invalidation later.
    ref.invalidate(historyControllerProvider);
    ref.invalidate(myStatsControllerProvider);
    final String? statsUserId = ref
        .read(currentUserControllerProvider)
        .data
        ?.id;
    if (statsUserId != null) {
      unawaited(ref.read(myStatsControllerProvider.notifier).load(statsUserId));
    }
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logGameComplete(
            mode: 'solo',
            categoryId: category.id,
            xpEarned: xpEarned,
            ballEarned: ballEarned,
          ),
    );
  }
}

final NotifierProvider<QuizController, QuizSessionState>
quizControllerProvider = NotifierProvider<QuizController, QuizSessionState>(
  QuizController.new,
);
