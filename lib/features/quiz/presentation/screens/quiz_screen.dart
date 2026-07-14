import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../widgets/timer_track.dart';

/// The question-answer loop — mirrors the prototype's `view-quiz`.
///
/// CURRENT STATE: presentation only, [QuizQuestionBank] placeholder
/// questions (5 per category, shuffled each attempt) — once the quiz
/// data layer exists these come from the backend along with real-time
/// duel/lobby state. Each question gets 15 seconds (mirrors the
/// prototype's `.timer-track`); running out of time locks in a wrong
/// answer automatically, same as picking one. The back button abandons
/// the quiz and returns straight to Home (matches the prototype's
/// `data-nav="home"` — no confirmation dialog).
class QuizScreen extends StatefulWidget {
  const QuizScreen({required this.category, super.key});

  final QuizCategory category;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  static const Duration _perQuestionDuration = Duration(seconds: 15);
  static const Duration _feedbackDelay = Duration(milliseconds: 900);
  static const int _xpPerCorrectAnswer = 15;

  late final List<QuizQuestion> _questions;
  late final AnimationController _timerController;
  Timer? _feedbackTimer;

  int _index = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _questions = List.of(QuizQuestionBank.forCategory(widget.category.name))..shuffle();
    _timerController = AnimationController(vsync: this, duration: _perQuestionDuration)
      ..addStatusListener(_onTimerStatusChanged)
      ..forward();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  QuizQuestion get _current => _questions[_index];

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_answered) {
      _lockInAnswer(null);
    }
  }

  void _lockInAnswer(int? pickedIndex) {
    if (_answered) return;
    _timerController.stop();
    setState(() {
      _answered = true;
      _selectedIndex = pickedIndex;
      if (pickedIndex == _current.correctIndex) _correctCount++;
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
        xpEarned: _correctCount * _xpPerCorrectAnswer,
      );
      context.pushReplacement(AppRoutes.result, extra: result);
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
                score: _correctCount * _xpPerCorrectAnswer,
                onBack: () => context.go(AppRoutes.home),
              ),
              AppSpacing.lg.vGap,
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) => TimerTrack(progress: 1 - _timerController.value),
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
