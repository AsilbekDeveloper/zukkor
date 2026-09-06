import 'package:flutter/material.dart';

/// Animates an integer counting up (or down) toward [value] whenever it
/// changes, instead of the displayed number just snapping into place -
/// e.g. XP/rank counting up when stats first load.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 700),
    super.key,
  });

  final int value;
  final String Function(int) formatter;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) => Text(formatter(animatedValue), style: style),
    );
  }
}
