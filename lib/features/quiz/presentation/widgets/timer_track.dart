import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';

/// The per-question countdown bar — mirrors the prototype's
/// `.timer-track`. [progress] is 1.0 (full time left) down to 0.0
/// (time's up).
class TimerTrack extends StatelessWidget {
  const TimerTrack({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: progress.clamp(0, 1),
          backgroundColor: context.colors.line,
          valueColor: AlwaysStoppedAnimation(context.colors.coralDeep),
        ),
      ),
    );
  }
}
