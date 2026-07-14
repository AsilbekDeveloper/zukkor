import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// 3 pulsing dots + a status text, shown while waiting on someone else —
/// mirrors the prototype's `.lobby-waiting` / `.waiting-dot` (`dot-pulse`
/// keyframes: staggered 0/0.15s/0.3s delay). Used by the Lobby (waiting
/// for the host) and Duel Waiting (waiting for the opponent's answer)
/// screens, with a different [label] for each.
class LobbyWaitingIndicator extends StatefulWidget {
  const LobbyWaitingIndicator({this.label = AppStrings.waitingForHostLabel, super.key});

  final String label;

  @override
  State<LobbyWaitingIndicator> createState() => _LobbyWaitingIndicatorState();
}

class _LobbyWaitingIndicatorState extends State<LobbyWaitingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++) ...[
              _PulsingDot(controller: _controller, delayFraction: i * 0.125),
              if (i < 2) AppSpacing.xs.hGap,
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.controller, required this.delayFraction});

  final AnimationController controller;
  final double delayFraction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Mirrors `dot-pulse`: low (0.25 opacity, 0.85 scale) most of the
        // cycle, peaking (1.0 opacity, 1.1 scale) briefly at 30% —
        // staggered per dot via [delayFraction].
        final double t = (controller.value + delayFraction) % 1.0;
        final double pulse = t < 0.3 ? t / 0.3 : (1 - (t - 0.3) / 0.7).clamp(0.0, 1.0);
        final double opacity = 0.25 + 0.75 * pulse;
        final double scale = 0.85 + 0.25 * pulse;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.coral),
            ),
          ),
        );
      },
    );
  }
}
