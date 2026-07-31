import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';

/// Visible per-question countdown ring — repaints on every tick of
/// [controller] (an `AnimationController` running 0 -> 1 over the
/// question's time limit) without needing the whole screen to rebuild.
/// Turns red for the final 5 seconds as an urgency cue.
class QuestionTimer extends AnimatedWidget {
  const QuestionTimer({required AnimationController controller, super.key}) : super(listenable: controller);

  AnimationController get _controller => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    final double progress = _controller.value.clamp(0.0, 1.0);
    final int totalSeconds = (_controller.duration!.inMilliseconds / 1000).ceil();
    final int secondsLeft = (totalSeconds * (1 - progress)).ceil().clamp(0, totalSeconds);
    final bool urgent = secondsLeft <= 5;
    final Color color = urgent ? context.colors.error : context.colors.coralDeep;

    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              value: 1 - progress,
              strokeWidth: 3,
              backgroundColor: context.colors.line,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
