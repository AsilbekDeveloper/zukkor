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
import '../../domain/entities/lobby_question_result.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../controllers/lobby_controller.dart';
import '../models/lobby_game_state.dart';
import '../models/lobby_result_args.dart';

/// The synchronized room question-answer loop — mirrors [DuelGameScreen]'s
/// timer/answer mechanics, but for N players instead of 2: instead of a
/// single "opponent answered" line, this shows a live "X/N answered"
/// count, and there's no per-opponent reveal — only this player's own
/// correctness (the room's overall standings only settle at the end,
/// see [LobbyResultScreen]).
class LobbyGameScreen extends ConsumerStatefulWidget {
  const LobbyGameScreen({super.key});

  @override
  ConsumerState<LobbyGameScreen> createState() => _LobbyGameScreenState();
}

class _LobbyGameScreenState extends ConsumerState<LobbyGameScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _timerController;

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
      _sync(ref.read(lobbyControllerProvider).game);
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final LobbyGameState? game = ref.read(lobbyControllerProvider).game;
    if (game == null || game.hasAnswered) return;
    ref.read(lobbyControllerProvider.notifier).submitAnswer(null);
  }

  void _sync(LobbyGameState? game) {
    if (game == null) return;

    if (game.finalResult != null) {
      if (_navigatedToResult) return;
      final LobbyRoomState? room = ref.read(lobbyControllerProvider).room;
      if (room == null) return;
      _navigatedToResult = true;
      context.pushReplacement(
        AppRoutes.lobbyResult,
        extra: LobbyResultArgs(room: room, result: game.finalResult!),
      );
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
    ref.read(lobbyControllerProvider.notifier).submitAnswer(index);
  }

  AnswerVisualState _stateFor(int optionIndex, LobbyGameState game) {
    final LobbyQuestionResult? result = game.lastResult;
    if (result == null) return AnswerVisualState.idle;
    if (optionIndex == result.yourSelectedOption) {
      return result.yourCorrect ? AnswerVisualState.pickedCorrect : AnswerVisualState.pickedWrong;
    }
    if (optionIndex == result.correctOption) return AnswerVisualState.revealCorrect;
    return AnswerVisualState.idle;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(lobbyControllerProvider, (previous, next) => _sync(next.game));
    final LobbyGameState? game = ref.watch(lobbyControllerProvider).game;

    if (game == null || game.question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int totalPlayers = ref.watch(lobbyControllerProvider).room?.participants.length ?? 0;

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
              if (game.lastResult == null && totalPlayers > 0)
                Center(
                  child: Text(
                    context.t.lobbyGame.answeredProgress(answered: game.answeredCount, total: totalPlayers),
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
