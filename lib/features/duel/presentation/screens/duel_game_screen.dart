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
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/widgets/answer_button.dart';
import '../../../quiz/presentation/widgets/question_card.dart';
import '../../../quiz/presentation/widgets/quiz_progress_header.dart';
import '../../domain/entities/duel_question_result.dart';
import '../controllers/duel_controller.dart';
import '../models/duel_game_state.dart';

/// The synchronized duel question-answer loop — mirrors [QuizScreen]'s
/// timer/answer mechanics, but the question, the timer duration, and the
/// reveal are all driven by [DuelController]'s live socket state instead
/// of a local question bank, since both players must see the same thing
/// at the same time.
class DuelGameScreen extends ConsumerStatefulWidget {
  const DuelGameScreen({super.key});

  @override
  ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends ConsumerState<DuelGameScreen> with SingleTickerProviderStateMixin {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sync(ref.read(duelControllerProvider).game);
    });
  }

  @override
  void dispose() {
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
    ref.read(duelControllerProvider.notifier).submitAnswer(index);
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
    ref.listen(duelControllerProvider, (previous, next) => _sync(next.game));
    final DuelGameState? game = ref.watch(duelControllerProvider).game;

    if (game == null || game.question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad, vertical: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizProgressHeader(
                questionNumber: game.questionIndex + 1,
                totalQuestions: game.totalQuestions,
                score: _correctCount,
                onBack: () => context.go(AppRoutes.home),
              ),
              AppSpacing.lg.vGap,
              QuestionCard(categoryName: game.category.name, question: game.question!.text),
              AppSpacing.sm.vGap,
              if (game.opponentHasAnswered && game.lastResult == null)
                Center(
                  child: Text(
                    context.t.duelGame.opponentAnswered,
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
    );
  }
}
