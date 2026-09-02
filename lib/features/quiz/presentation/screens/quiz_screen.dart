import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/game_status_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../domain/entities/answer_result.dart';
import '../../domain/entities/quiz_question_data.dart';
import '../controllers/quiz_controller.dart';
import '../models/quiz_category.dart';
import '../models/quiz_result.dart';
import '../widgets/answer_button.dart';
import '../widgets/question_card.dart';
import '../widgets/question_timer.dart';
import '../widgets/quiz_progress_header.dart';

/// The question-answer loop — mirrors the prototype's `view-quiz`. Runs the
/// real `POST /quiz/start` / `POST /quiz/{session_id}/answer` session loop
/// for [category] (Categories/Home → Setup → Intro, and Duel all pick from
/// the same real category grid) — scoring is server-authoritative.
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

class _QuizScreenState extends ConsumerState<QuizScreen> with SingleTickerProviderStateMixin {
  static const Duration _feedbackDelay = Duration(milliseconds: 900);
  static const Duration _fallbackTimeLimit = Duration(seconds: 15);

  late final AnimationController _timerController;
  Timer? _pauseTimer;

  bool _answered = false;
  int? _selectedIndex;

  bool _starting = true;
  String? _sessionId;
  QuizQuestionData? _currentQuestion;
  int? _lastCorrectIndex;
  AnswerResult? _pendingAnswerResult;
  int _totalBall = 0;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this, duration: _fallbackTimeLimit)
      ..addStatusListener(_onTimerStatusChanged);
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
      final result = await ref.read(quizControllerProvider.notifier).startQuiz(
            categoryId: widget.category.id,
            questionCount: widget.questionCount,
          );
      if (!mounted) return;
      setState(() {
        _sessionId = result.sessionId;
        _currentQuestion = result.question;
        _starting = false;
      });
      unawaited(ref.read(analyticsServiceProvider).logGameStart(mode: 'solo', categoryId: widget.category.id));
      _timerController.duration = Duration(milliseconds: _currentQuestion!.timeLimitMs);
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
    if (status == AnimationStatus.completed && !_answered) {
      _lockInAnswer(null);
    }
  }

  void _lockInAnswer(int? pickedIndex) {
    if (_answered || _starting) return;
    unawaited(_lockInAnswerReal(pickedIndex));
  }

  Future<void> _lockInAnswerReal(int? pickedIndex) async {
    _timerController.stop();
    final int correctIndex = _currentQuestion!.correctOptionIndex;
    setState(() {
      _answered = true;
      _selectedIndex = pickedIndex;
      _lastCorrectIndex = correctIndex;
    });
    ref.playSound(pickedIndex == correctIndex ? AppSound.correct : AppSound.wrong);

    // The network round trip and the minimum "let the user see the
    // reveal" pause run CONCURRENTLY, not one after the other — a slow
    // network no longer stacks on top of the fixed pause (previously the
    // wait was network_time + 900ms; now it's max(network_time, 900ms)).
    final Future<AnswerResult> answerFuture = ref.read(quizControllerProvider.notifier).submitAnswer(
          sessionId: _sessionId!,
          sessionQuestionId: _currentQuestion!.sessionQuestionId,
          selectedOption: pickedIndex,
        );
    final Future<void> pauseFuture = _pause(_feedbackDelay);

    try {
      final AnswerResult result = (await Future.wait([answerFuture, pauseFuture]))[0] as AnswerResult;
      if (!mounted) return;
      setState(() {
        _totalBall += result.ballEarned;
        _pendingAnswerResult = result;
      });
      _advanceReal();
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

  void _advanceReal() {
    if (!mounted) return;
    final AnswerResult result = _pendingAnswerResult!;

    if (result.isSessionComplete) {
      final summary = result.summary!;
      final QuizResult quizResult = QuizResult(
        category: widget.category,
        correctCount: summary.correctCount,
        totalCount: summary.totalQuestions,
        xpEarned: summary.xpEarned,
        totalBall: summary.totalBall,
        breakdown: summary.breakdown,
      );
      // This session's own XP/history just changed server-side — drop
      // the cached copies so History/Home/Profile fetch fresh next time
      // they're visited, instead of showing the pre-game snapshot.
      ref.invalidate(historyControllerProvider);
      ref.invalidate(myStatsControllerProvider);
      ref.read(analyticsServiceProvider).logGameComplete(
            mode: 'solo',
            categoryId: widget.category.id,
            xpEarned: summary.xpEarned,
            ballEarned: summary.totalBall,
          );
      context.pushReplacement(AppRoutes.ballReveal, extra: quizResult);
      return;
    }

    setState(() {
      _currentQuestion = result.nextQuestion;
      _answered = false;
      _selectedIndex = null;
      _lastCorrectIndex = null;
      _pendingAnswerResult = null;
    });
    _timerController
      ..duration = Duration(milliseconds: _currentQuestion!.timeLimitMs)
      ..reset()
      ..forward();
  }

  AnswerVisualState _stateFor(int optionIndex, int? correctIndex) {
    if (!_answered || correctIndex == null) return AnswerVisualState.idle;
    if (optionIndex == _selectedIndex) {
      return optionIndex == correctIndex ? AnswerVisualState.pickedCorrect : AnswerVisualState.pickedWrong;
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
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.t.gameLeave.stay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.t.gameLeave.leave,
              style: TextStyle(color: context.colors.error, fontWeight: FontWeight.w700),
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
    if (_starting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final QuizQuestionData question = _currentQuestion!;
    final int questionNumber = question.order;
    final int totalQuestions = question.total;
    final String questionText = question.questionText;
    final List<String> options = question.options;
    final int score = _totalBall;
    final int? correctIndexForDisplay = _lastCorrectIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.screenHPad, vertical: AppSpacing.xs),
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
                QuestionCard(categoryName: widget.category.name, question: questionText),
                AppSpacing.lg.vGap,
                for (int i = 0; i < options.length; i++) ...[
                  AnswerButton(
                    letter: String.fromCharCode(65 + i),
                    text: options[i],
                    state: _stateFor(i, correctIndexForDisplay),
                    onTap: _answered ? null : () => _lockInAnswer(i),
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
