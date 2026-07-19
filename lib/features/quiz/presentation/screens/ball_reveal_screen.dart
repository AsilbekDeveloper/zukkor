import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/audio/app_sound.dart';
import '../../../../core/audio/sound_controller.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../../introduction/presentation/widgets/confetti_burst.dart';
import '../models/quiz_result.dart';

/// A short celebratory pause between finishing a quiz and [ResultScreen]:
/// the session's total ball counts up from 0, then a confetti burst
/// fires and the XP it converts into fades in — purely transitional,
/// isn't meant to be interacted with, mirrors [QuizIntroScreen]'s
/// auto-advancing pattern.
class BallRevealScreen extends ConsumerStatefulWidget {
  const BallRevealScreen({required this.result, super.key});

  final QuizResult result;

  @override
  ConsumerState<BallRevealScreen> createState() => _BallRevealScreenState();
}

class _BallRevealScreenState extends ConsumerState<BallRevealScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _countDuration = Duration(milliseconds: 1400);

  late final AnimationController _countController;
  late final Animation<int> _ballAnimation;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(vsync: this, duration: _countDuration)
      ..addStatusListener(_onStatusChanged);
    _ballAnimation = IntTween(begin: 0, end: widget.result.totalBall).animate(
      CurvedAnimation(parent: _countController, curve: AppDurations.ease),
    );
    _countController.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() => _revealed = true);
    ref.playSound(AppSound.success);
  }

  void _finish() {
    if (!mounted) return;
    context.pushReplacement(AppRoutes.result, extra: widget.result);
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.result.category.color(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t.ballReveal.title,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.colors.ink,
                      ),
                    ),
                    AppSpacing.lg.vGap,
                    AnimatedBuilder(
                      animation: _ballAnimation,
                      builder: (context, child) => Text(
                        '${_ballAnimation.value}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.t.ballReveal.ballLabel,
                      style: context.textStyles.labelSmall,
                    ),
                    AppSpacing.xl.vGap,
                    AnimatedOpacity(
                      opacity: _revealed ? 1 : 0,
                      duration: AppDurations.slow,
                      curve: AppDurations.ease,
                      child: AnimatedScale(
                        scale: _revealed ? 1 : 0.8,
                        duration: AppDurations.slow,
                        curve: AppDurations.ease,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.colors.coralDeep,
                            borderRadius: AppRadius.lgAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(TablerIcons.bolt, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                context.t.result.xpEarned(xp: widget.result.xpEarned),
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_revealed)
              Positioned.fill(
                child: ConfettiBurst(
                  colors: [
                    context.colors.coral,
                    context.colors.teal,
                    context.colors.pink,
                    context.colors.green,
                    context.colors.blue,
                  ],
                  onDone: _finish,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
