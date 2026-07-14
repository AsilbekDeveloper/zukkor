import 'package:flutter/material.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';

/// Big animated score ring — mirrors the prototype's `.score-ring`
/// (animates from 0 to [percent] once, matching `animateScoreRing()`).
class ScoreRing extends StatelessWidget {
  const ScoreRing({required this.percent, super.key});

  final double percent;

  static const double _size = 140;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: percent.clamp(0, 1)),
        duration: AppDurations.slow + const Duration(milliseconds: 700),
        curve: AppDurations.ease,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: _size,
              height: _size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor: context.colors.line,
                valueColor: AlwaysStoppedAnimation(context.colors.coralDeep),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: context.colors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
