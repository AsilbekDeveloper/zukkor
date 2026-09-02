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
import '../../../../core/state/game_status_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/widgets/answer_button.dart';
import '../../../quiz/presentation/widgets/question_card.dart';
import '../../../quiz/presentation/widgets/question_timer.dart';
import '../../../quiz/presentation/widgets/quiz_progress_header.dart';
import '../../domain/entities/lobby_question_result.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../controllers/lobby_controller.dart';
import '../models/lobby_game_state.dart';
import '../models/lobby_result_args.dart';

/// The room question-answer loop — mirrors [DuelGameScreen]'s timer/answer
/// mechanics, but for N players instead of 2. Each player answers at
/// their own pace; there's no per-opponent reveal, only this player's own
/// correctness (the room's overall standings only settle at the end, see
/// [LobbyResultScreen]) — this screen switches to a "waiting for others"
/// state once this player has finished every question but the room
/// hasn't.
class LobbyGameScreen extends ConsumerStatefulWidget {
  const LobbyGameScreen({super.key});

  @override
  ConsumerState<LobbyGameScreen> createState() => _LobbyGameScreenState();
}

class _LobbyGameScreenState extends ConsumerState<LobbyGameScreen> with SingleTickerProviderStateMixin {
  // A lost/dropped `lobby_game_started`/`lobby_question` (the same class
  // of socket-delivery gap as room creation) otherwise left this screen
  // on a bare, header-less spinner forever — and there's no screen left
  // underneath to fall back to (this replaced Lobby via pushReplacement).
  // This is the safety net for that.
  static const Duration _startTimeout = Duration(seconds: 20);
  Timer? _startTimeoutTimer;
  bool _startFailed = false;

  // Purely cosmetic on this end — the server holds off broadcasting the
  // first question for the same span (see lobby_manager.start_game), so
  // this doesn't eat into anyone's real answer time.
  static const int _preGameCountdownStart = 5;
  int _preGameCountdown = _preGameCountdownStart;
  Timer? _preGameCountdownTimer;

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
    _startTimeoutTimer = Timer(_startTimeout, () {
      if (mounted) setState(() => _startFailed = true);
    });
    _preGameCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _preGameCountdown <= 0) return;
      setState(() => _preGameCountdown--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(isInActiveGameProvider.notifier).setInGame(true);
      _sync(ref.read(lobbyControllerProvider).game);
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (mounted) {
        ref.read(isInActiveGameProvider.notifier).setInGame(false);
      }
    });
    _startTimeoutTimer?.cancel();
    _preGameCountdownTimer?.cancel();
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
    if (game.question != null) {
      _startTimeoutTimer?.cancel();
      _preGameCountdownTimer?.cancel();
    }

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
    _timerController.stop();
    ref.read(lobbyControllerProvider.notifier).submitAnswer(index);
  }

  Future<void> _onBack() async {
    final bool? leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t.gameLeave.lobbyTitle),
        content: Text(context.t.gameLeave.lobbyMessage),
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
      ref.read(lobbyControllerProvider.notifier).leaveRoom();
      context.go(AppRoutes.home);
    }
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

    if (game != null && game.waitingForOthers && game.finalResult == null) {
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
                  CloseHeader(title: context.t.lobbyGame.title, onClose: _onBack),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          AppSpacing.lg.vGap,
                          Text(
                            context.t.lobbyGame.waitingForOthers,
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
                CloseHeader(title: context.t.lobbyGame.title, onClose: () => context.go(AppRoutes.home)),
                Expanded(
                  child: Center(
                    child: _startFailed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.t.lobbyGame.startFailed,
                                textAlign: TextAlign.center,
                                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.coralDeep),
                              ),
                              AppSpacing.lg.vGap,
                              AppButton.secondary(
                                label: context.t.lobbyGame.backToHome,
                                onPressed: () => context.go(AppRoutes.home),
                              ),
                            ],
                          )
                        : game != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.t.lobbyGame.waitingForQuestion,
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
