import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/quiz_category.dart';
import '../models/quiz_question.dart';
import '../models/quiz_question_bank.dart';
import '../models/quiz_result.dart';
import '../widgets/answer_button.dart';
import '../widgets/question_card.dart';
import '../widgets/quiz_progress_header.dart';

/// The question-answer loop — mirrors the prototype's `view-quiz`.
///
/// CURRENT STATE: presentation only, [QuizQuestionBank] placeholder
/// questions (5 per category, shuffled each attempt) — once the quiz
/// data layer exists these come from the backend along with real-time
/// duel/lobby state. Each question gets 15 seconds; running out of time
/// locks in a wrong answer automatically, same as picking one. No
/// countdown is shown to the player — it only drives scoring in the
/// background (see [_startSpeedTimer]). Locking in an answer plays
/// [AppSound.correct] or [AppSound.wrong]. The back button abandons the
/// quiz and returns straight to Home (matches the prototype's
/// `data-nav="home"` — no confirmation dialog).
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({required this.category, this.isLobbyGame = false, super.key});

  final QuizCategory category;

  /// Set when reached from the Lobby (multiplayer room) — changes the
  /// destination once every question is answered from the plain
  /// [ResultScreen] to [LobbyResultScreen] (a room leaderboard).
  final bool isLobbyGame;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with SingleTickerProviderStateMixin {
  static const Duration _perQuestionDuration = Duration(seconds: 15);
  static const Duration _feedbackDelay = Duration(milliseconds: 900);
  static const int _xpPerCorrectAnswer = 15;

  // Kahoot-style hidden per-question score: never shown to the player,
  // just ticked down every 10ms and used to scale the XP a correct
  // answer earns (see [_lockInAnswer]).
  static const int _pointsMax = 1000;
  static const Duration _speedTick = Duration(milliseconds: 10);
  static const int _speedTicksPerQuestion = 1500; // _perQuestionDuration ÷ _speedTick
  static const double _pointsDecrementPerTick = _pointsMax / _speedTicksPerQuestion;

  late final List<QuizQuestion> _questions;
  late final AnimationController _timerController;
  Timer? _feedbackTimer;
  Timer? _speedTimer;
  double _pointsRemaining = _pointsMax.toDouble();

  int _index = 0;
  int _correctCount = 0;
  int _totalXp = 0;
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = List.of(QuizQuestionBank.forCategory(widget.category.name))..shuffle();
    _timerController = AnimationController(vsync: this, duration: _perQuestionDuration)
      ..addStatusListener(_onTimerStatusChanged)
      ..forward();
    _startSpeedTimer();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _speedTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  QuizQuestion get _current => _questions[_index];

  /// Resets the hidden 1000 → 0 point countdown for a fresh question. It
  /// isn't rendered anywhere, so this deliberately skips `setState` —
  /// there's nothing on screen for it to invalidate.
  void _startSpeedTimer() {
    _pointsRemaining = _pointsMax.toDouble();
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(_speedTick, (_) {
      _pointsRemaining = (_pointsRemaining - _pointsDecrementPerTick).clamp(0, _pointsMax.toDouble());
    });
  }

  /// Kahoot's own formula: a correct answer earns between 500 (right at
  /// the buzzer) and 1000 (instant) points, scaled by how much of the
  /// hidden countdown is left when it's answered.
  int _kahootPoints() => (_pointsMax * (0.5 + (_pointsRemaining / _pointsMax) * 0.5)).round();

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_answered) {
      _lockInAnswer(null);
    }
  }

  void _lockInAnswer(int? pickedIndex) {
    if (_answered) return;
    _timerController.stop();
    _speedTimer?.cancel();

    final bool isCorrect = pickedIndex == _current.correctIndex;
    // Points convert 1:1 into the app's XP economy at _xpPerCorrectAnswer
    // per full 1000 — an instant correct answer earns the full 15 XP, a
    // last-moment one about half.
    final int earnedXp =
        isCorrect ? (_kahootPoints() / _pointsMax * _xpPerCorrectAnswer).round() : 0;
    ref.playSound(isCorrect ? AppSound.correct : AppSound.wrong);

    setState(() {
      _answered = true;
      _selectedIndex = pickedIndex;
      if (isCorrect) {
        _correctCount++;
        _totalXp += earnedXp;
      }
    });
    _feedbackTimer = Timer(_feedbackDelay, _advance);
  }

  void _advance() {
    if (!mounted) return;

    if (_index + 1 >= _questions.length) {
      final QuizResult result = QuizResult(
        category: widget.category,
        correctCount: _correctCount,
        totalCount: _questions.length,
        xpEarned: _totalXp,
      );
      final String destination = widget.isLobbyGame ? AppRoutes.lobbyResult : AppRoutes.result;
      context.pushReplacement(destination, extra: result);
      return;
    }

    setState(() {
      _index++;
      _answered = false;
      _selectedIndex = null;
    });
    _timerController
      ..reset()
      ..forward();
    _startSpeedTimer();
  }

  AnswerVisualState _stateFor(int optionIndex) {
    if (!_answered) return AnswerVisualState.idle;
    if (optionIndex == _selectedIndex) {
      return optionIndex == _current.correctIndex
          ? AnswerVisualState.pickedCorrect
          : AnswerVisualState.pickedWrong;
    }
    if (optionIndex == _current.correctIndex) return AnswerVisualState.revealCorrect;
    return AnswerVisualState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final QuizQuestion question = _current;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad, vertical: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuizProgressHeader(
                questionNumber: _index + 1,
                totalQuestions: _questions.length,
                score: _totalXp,
                onBack: () => context.go(AppRoutes.home),
              ),
              AppSpacing.lg.vGap,
              QuestionCard(categoryName: widget.category.name, question: question.text),
              AppSpacing.lg.vGap,
              for (int i = 0; i < question.options.length; i++) ...[
                AnswerButton(
                  letter: String.fromCharCode(65 + i),
                  text: question.options[i],
                  state: _stateFor(i),
                  onTap: _answered ? null : () => _lockInAnswer(i),
                ),
                if (i < question.options.length - 1) AppSpacing.sm.vGap,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
