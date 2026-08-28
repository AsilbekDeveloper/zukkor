import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/widgets/answer_button.dart';
import '../../../quiz/presentation/widgets/question_card.dart';
import '../../../quiz/presentation/widgets/question_timer.dart';
import '../../../quiz/presentation/widgets/quiz_progress_header.dart';
import '../../domain/entities/duel_question_result.dart';
import '../controllers/duel_controller.dart';
import '../models/duel_game_state.dart';

/// The duel question-answer loop — mirrors [QuizScreen]'s timer/answer
/// mechanics, but the question, the timer duration, and the reveal are
/// all driven by [DuelController]'s live socket state instead of a
/// local question bank. Both players see the same question set, but
/// each answers at their own pace (no waiting on the other one mid-
/// question) — this screen switches to a "waiting for opponent" state
/// once this player has finished every question but the other hasn't.
class DuelGameScreen extends ConsumerStatefulWidget {
  const DuelGameScreen({super.key});

  @override
  ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends ConsumerState<DuelGameScreen> with SingleTickerProviderStateMixin {
  // A lost/dropped `duel_started`/`duel_question` (the same class of
  // socket-delivery gap as invites) otherwise left this screen on a
  // bare, header-less spinner forever — and unlike Duel Waiting, there's
  // no screen left underneath to fall back to (this replaced it via
  // pushReplacement). This is the safety net for that.
  static const Duration _startTimeout = Duration(seconds: 20);
  Timer? _startTimeoutTimer;
  bool _startFailed = false;

  // Purely cosmetic on this end — the server holds off broadcasting the
  // first question for the same span (see duel_engine.start_duel), so
  // this doesn't eat into anyone's real answer time.
  static const int _preGameCountdownStart = 5;
  int _preGameCountdown = _preGameCountdownStart;
  Timer? _preGameCountdownTimer;

  late final AnimationController _timerController;

  // Guards so the per-question side effects below (start timer, play a
  // sound, tally the running score, navigate to the result) each fire
  // exactly once per question/duel, no matter how many times _sync runs.
  int? _timerStartedForIndex;
  int? _revealedForIndex;
  bool _navigatedToResult = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addStatusListener(_onTimerStatusChanged);
    _startTimeoutTimer = Timer(_startTimeout, () {
      if (mounted) setState(() => _startFailed = true);
    });
    _preGameCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _preGameCountdown <= 0) return;
      setState(() => _preGameCountdown--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sync(ref.read(duelControllerProvider).game);
    });
  }

  @override
  void dispose() {
    _startTimeoutTimer?.cancel();
    _preGameCountdownTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final DuelGameState? game = ref.read(duelControllerProvider).game;
    if (game == null || game.hasAnswered) return;
    ref.read(duelControllerProvider.notifier).submitAnswer(null);
  }

  void _sync(DuelGameState? game) {
    if (game == null) return;
    if (game.question != null) {
      _startTimeoutTimer?.cancel();
      _preGameCountdownTimer?.cancel();
    }

    if (game.finalResult != null) {
      if (_navigatedToResult) return;
      _navigatedToResult = true;
      context.pushReplacement(AppRoutes.duelResult, extra: game);
      return;
    }

    if (game.lastResult != null && _revealedForIndex != game.lastResult!.questionIndex) {
      _revealedForIndex = game.lastResult!.questionIndex;
      if (game.lastResult!.yourCorrect) _correctCount++;
      ref.playSound(game.lastResult!.yourCorrect ? AppSound.correct : AppSound.wrong);
    }

    if (game.question != null && !game.hasAnswered && _timerStartedForIndex != game.questionIndex) {
      _timerStartedForIndex = game.questionIndex;
      _timerController
        ..stop()
        ..duration = Duration(milliseconds: game.question!.timeLimitMs)
        ..reset()
        ..forward();
    }
  }

  void _selectAnswer(int index) {
    _timerController.stop();
    ref.read(duelControllerProvider.notifier).submitAnswer(index);
  }

  Future<void> _onBack() async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.gameLeave.duelTitle),
        content: Text(context.t.gameLeave.duelMessage),
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
      ref.read(duelControllerProvider.notifier).leaveDuel();
      context.go(AppRoutes.home);
    }
  }

  Future<void> _onCancelled() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.gameLeave.opponentLeft),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.t.common.ok),
          ),
        ],
      ),
    );
    if (mounted) {
      ref.read(duelControllerProvider.notifier).clearGame();
      context.go(AppRoutes.home);
    }
  }

  AnswerVisualState _stateFor(int optionIndex, DuelGameState game) {
    final DuelQuestionResult? result = game.lastResult;
    if (result == null) return AnswerVisualState.idle;
    if (optionIndex == result.yourSelectedOption) {
      return result.yourCorrect ? AnswerVisualState.pickedCorrect : AnswerVisualState.pickedWrong;
    }
    if (optionIndex == result.correctOption) return AnswerVisualState.revealCorrect;
    return AnswerVisualState.idle;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(duelControllerProvider, (previous, next) {
      _sync(next.game);
      if (next.wasCancelled && !(previous?.wasCancelled ?? false)) {
        _onCancelled();
      }
    });
    final DuelGameState? game = ref.watch(duelControllerProvider).game;

    if (game != null && game.waitingForOpponent && game.finalResult == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBack();
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.xs.vGap,
                  CloseHeader(title: context.t.duelGame.title, onClose: _onBack),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          AppSpacing.lg.vGap,
                          Text(
                            context.t.duelGame.waitingForOpponent,
                            textAlign: TextAlign.center,
                            style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (game == null || game.question == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.xs.vGap,
                CloseHeader(title: context.t.duelGame.title, onClose: () => context.go(AppRoutes.home)),
                Expanded(
                  child: Center(
                    child: _startFailed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.t.duelGame.startFailed,
                                textAlign: TextAlign.center,
                                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.coralDeep),
                              ),
                              AppSpacing.lg.vGap,
                              AppButton.secondary(
                                label: context.t.duelGame.backToHome,
                                onPressed: () => context.go(AppRoutes.home),
                              ),
                            ],
                          )
                        : game != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.t.duelGame.waitingForQuestion,
                                    style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
                                  ),
                                  AppSpacing.md.vGap,
                                  Text(
                                    _preGameCountdown > 0 ? '$_preGameCountdown' : '!',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 56,
                                      color: context.colors.coralDeep,
                                    ),
                                  ),
                                ],
                              )
                            : const CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                        questionNumber: game.questionIndex + 1,
                        totalQuestions: game.totalQuestions,
                        score: _correctCount,
                        onBack: _onBack,
                      ),
                    ),
                    AppSpacing.sm.hGap,
                    QuestionTimer(controller: _timerController),
                  ],
                ),
                AppSpacing.lg.vGap,
                QuestionCard(categoryName: game.category.name, question: game.question!.text),
                AppSpacing.sm.vGap,
                if (game.opponentQuestionIndex != null)
                  Center(
                    child: Text(
                      context.t.duelGame.opponentProgress(
                        index: game.opponentQuestionIndex! + 1,
                        total: game.totalQuestions,
                      ),
                      style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                    ),
                  ),
                AppSpacing.sm.vGap,
                for (int i = 0; i < game.question!.options.length; i++) ...[
                  AnswerButton(
                    letter: String.fromCharCode(65 + i),
                    text: game.question!.options[i],
                    state: _stateFor(i, game),
                    onTap: game.hasAnswered ? null : () => _selectAnswer(i),
                  ),
                  if (i < game.question!.options.length - 1) AppSpacing.sm.vGap,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
