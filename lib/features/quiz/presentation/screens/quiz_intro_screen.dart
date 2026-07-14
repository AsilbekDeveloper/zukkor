import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/quiz_category.dart';
import '../models/quiz_launch_args.dart';

/// Short "5, 4, 3, 2, 1, Start!" countdown shown right after a category
/// is picked — mirrors the prototype's `view-quiz-intro` /
/// `startQuizIntro()`. Purely transitional: it isn't meant to be
/// interacted with, it just auto-advances to [QuizScreen].
class QuizIntroScreen extends StatefulWidget {
  const QuizIntroScreen({required this.category, super.key});

  final QuizCategory category;

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  static const int _startCount = 5;
  static const Duration _tickInterval = Duration(milliseconds: 700);
  static const Duration _startHoldDuration = Duration(milliseconds: 550);

  int _count = _startCount;
  Timer? _tickTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(_tickInterval, _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    setState(() => _count--);
    if (_count == 0) {
      timer.cancel();
      _navigateTimer = Timer(_startHoldDuration, () {
        if (!mounted) return;
        context.pushReplacement(AppRoutes.quiz, extra: QuizLaunchArgs(category: widget.category));
      });
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isStart = _count == 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.category.color(context),
                    borderRadius: AppRadius.mdAll,
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.category.icon, color: Colors.white, size: 28),
                ),
                AppSpacing.md.vGap,
                Text(
                  widget.category.name,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.ink,
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween(begin: 0.6, end: 1.0).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Text(
                    isStart ? AppStrings.quizStartLabel : '$_count',
                    key: ValueKey(isStart ? 'start' : _count),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: isStart ? 40 : 64,
                      fontWeight: FontWeight.w800,
                      color: context.colors.coral,
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
}
