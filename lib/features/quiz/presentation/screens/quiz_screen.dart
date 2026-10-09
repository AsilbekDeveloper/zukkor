import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/game_status_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/quiz_question_data.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_category.dart';
import '../widgets/answer_button.dart';
import '../widgets/question_card.dart';
import '../widgets/question_timer.dart';
import '../widgets/quiz_progress_header.dart';

/// The question-answer loop — mirrors the prototype's `view-quiz`. Runs the
/// real `POST /quiz/start` / `POST /quiz/{session_id}/answer` session loop
/// for [category] (Categories/Home → Setup → Intro, and Duel all pick from
/// the same real category grid) — scoring is server-authoritative.
///
/// The session itself (current question, running ball total, server
/// summary) lives in [QuizController] — this screen only renders that
/// state and drives navigation off it. The countdown [AnimationController]
/// and the leave-confirm dialog are the only things that stay here, since
/// those are genuinely view concerns.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    required this.category,
    this.questionCount = 10,
    super.key,
  });

  final QuizCategory category;
  final int questionCount;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _feedbackDelay = Duration(milliseconds: 900);
  static const Duration _fallbackTimeLimit = Duration(seconds: 15);

  late final AnimationController _timerController;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: _fallbackTimeLimit,
    )..addStatusListener(_onTimerStatusChanged);
    Future.microtask(() {
      ref.read(isInActiveGameProvider.notifier).setInGame(true);
      _startSession();
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (mounted) {
        ref.read(isInActiveGameProvider.notifier).setInGame(false);
      }
    });
    _pauseTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  /// Like `Future.delayed`, but backed by a cancellable `Timer` — so a
  /// widget disposed mid-wait (screen popped, test torn down) doesn't
  /// leave an orphaned timer running with nothing left to observe it.
  Future<void> _pause(Duration duration) {
    final Completer<void> completer = Completer<void>();
    _pauseTimer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  Future<void> _startSession() async {
    try {
      await ref
          .read(quizControllerProvider.notifier)
          .startSession(
            category: widget.category,
            questionCount: widget.questionCount,
          );
      if (!mounted) return;
      final QuizSessionState session = ref.read(quizControllerProvider);
      _timerController.duration = Duration(
        milliseconds: session.currentQuestion!.timeLimitMs,
      );
      unawaited(_timerController.forward());
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
      context.go(AppRoutes.home);
    }
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        !ref.read(quizControllerProvider).answered) {
      _lockInAnswer(null);
    }
  }

  void _lockInAnswer(int? pickedIndex) {
    final QuizSessionState session = ref.read(quizControllerProvider);
    if (session.answered || session.starting) return;
    unawaited(_lockInAnswerReal(pickedIndex));
  }

  Future<void> _lockInAnswerReal(int? pickedIndex) async {
    _timerController.stop();
    final bool wasCorrect =
        pickedIndex ==
        ref.read(quizControllerProvider).currentQuestion!.correctOptionIndex;
    // Duel/Lobby o'yin ekranlari bilan bir xil - alohida his qilinadigan
    // haptic ([[duel_game_screen]]).
    unawaited(
      wasCorrect ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact(),
    );

    // The network round trip and the minimum "let the user see the
    // reveal" pause run CONCURRENTLY, not one after the other — a slow
    // network no longer stacks on top of the fixed pause (previously the
    // wait was network_time + 900ms; now it's max(network_time, 900ms)).
    final Future<void> submitFuture = ref
        .read(quizControllerProvider.notifier)
        .submitAnswer(selectedOption: pickedIndex);
    final Future<void> pauseFuture = _pause(_feedbackDelay);

    try {
      await Future.wait([submitFuture, pauseFuture]);
      if (!mounted) return;
      ref
          .read(quizControllerProvider.notifier)
          .commitPendingResult(widget.category);
      final QuizSessionState session = ref.read(quizControllerProvider);
      if (session.result != null) {
        context.pushReplacement(AppRoutes.ballReveal, extra: session.result);
        return;
      }
      _timerController
        ..duration = Duration(
          milliseconds: session.currentQuestion!.timeLimitMs,
        )
        ..reset();
      unawaited(_timerController.forward());
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
      context.go(AppRoutes.home);
    }
  }

  AnswerVisualState _stateFor(
    int optionIndex,
    int? correctIndex,
    QuizSessionState session,
  ) {
    if (!session.answered || correctIndex == null) {
      return AnswerVisualState.idle;
    }
    if (optionIndex == session.selectedIndex) {
      return optionIndex == correctIndex
          ? AnswerVisualState.pickedCorrect
          : AnswerVisualState.pickedWrong;
    }
    if (optionIndex == correctIndex) return AnswerVisualState.revealCorrect;
    return AnswerVisualState.idle;
  }

  Future<void> _onBack() async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.gameLeave.soloTitle),
        content: Text(context.t.gameLeave.soloMessage),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(false);
            },
            child: Text(context.t.gameLeave.stay),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop(true);
            },
            child: Text(
              context.t.gameLeave.leave,
              style: TextStyle(
                color: context.colors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (leave == true && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuizSessionState session = ref.watch(quizControllerProvider);
    if (session.starting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final QuizQuestionData question = session.currentQuestion!;
    final int questionNumber = question.order;
    final int totalQuestions = question.total;
    final String questionText = question.questionText;
    final List<String> options = question.options;
    final int score = session.totalBall;
    final int? correctIndexForDisplay = session.lastCorrectIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenHPad,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: QuizProgressHeader(
                        questionNumber: questionNumber,
                        totalQuestions: totalQuestions,
                        score: score,
                        onBack: _onBack,
                      ),
                    ),
                    AppSpacing.sm.hGap,
                    QuestionTimer(controller: _timerController),
                  ],
                ),
                AppSpacing.lg.vGap,
                QuestionCard(
                  categoryName: widget.category.name,
                  question: questionText,
                ),
                AppSpacing.lg.vGap,
                for (int i = 0; i < options.length; i++) ...[
                  AnswerButton(
                    letter: String.fromCharCode(65 + i),
                    text: options[i],
                    state: _stateFor(i, correctIndexForDisplay, session),
                    onTap: session.answered ? null : () => _lockInAnswer(i),
                  ),
                  if (i < options.length - 1) AppSpacing.sm.vGap,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
