import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// One of the 4 "what is Zukkor" pages in the Introduction walkthrough —
/// a big colored icon badge that pops in with a staggered entrance
/// (icon → title → subtitle), then keeps a gentle "breathing" glow and a
/// few slow-drifting particles behind it so the page never feels static.
class IntroExplainerPage extends StatefulWidget {
  const IntroExplainerPage({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  State<IntroExplainerPage> createState() => _IntroExplainerPageState();
}

class _OrbitDot {
  const _OrbitDot({required this.radius, required this.phase, required this.size, required this.opacity});

  final double radius;

  /// 0..1 — offsets where this dot starts around the circle.
  final double phase;
  final double size;
  final double opacity;
}

const List<_OrbitDot> _orbitDots = [
  _OrbitDot(radius: 78, phase: 0, size: 10, opacity: 0.5),
  _OrbitDot(radius: 68, phase: 0.38, size: 7, opacity: 0.35),
  _OrbitDot(radius: 86, phase: 0.72, size: 8, opacity: 0.4),
];

class _IntroExplainerPageState extends State<IntroExplainerPage> with TickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  // Ambient motion — purely decorative, keeps running for as long as the
  // page is mounted (stopped and disposed together with it).
  late final AnimationController _breathController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);
  late final AnimationController _orbitController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  late final Animation<double> _iconScale = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0, 0.65, curve: Curves.elasticOut),
  );
  late final Animation<double> _iconOpacity = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );
  late final Animation<double> _titleAnim = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
  );
  late final Animation<double> _subtitleAnim = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _entranceController.dispose();
    _breathController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  Widget _buildOrbitDot(_OrbitDot dot, double orbitValue, double entranceOpacity) {
    final double angle = (orbitValue + dot.phase) * 2 * math.pi;
    final Offset offset = Offset(dot.radius * math.cos(angle), dot.radius * math.sin(angle));
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: dot.opacity * entranceOpacity,
        child: Container(
          width: dot.size,
          height: dot.size,
          decoration: BoxDecoration(color: widget.iconColor, shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSpacing.xl.vGap,
        SizedBox(
          width: 190,
          height: 190,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entranceController, _breathController, _orbitController]),
            builder: (context, child) {
              final double breathe = 1 + 0.045 * math.sin(_breathController.value * math.pi);
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final _OrbitDot dot in _orbitDots)
                    _buildOrbitDot(dot, _orbitController.value, _iconOpacity.value),
                  Transform.scale(
                    scale: _iconScale.value * breathe,
                    child: Opacity(
                      opacity: _iconOpacity.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: widget.iconColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.iconColor.withValues(alpha: 0.22 + 0.18 * _breathController.value),
                              blurRadius: 22 + 14 * _breathController.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(widget.icon, color: Colors.white, size: 56),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        AppSpacing.lg.vGap,
        FadeTransition(
          opacity: _titleAnim,
          child: SlideTransition(
            position: _titleAnim.drive(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.textStyles.headlineMedium,
            ),
          ),
        ),
        AppSpacing.sm.vGap,
        FadeTransition(
          opacity: _subtitleAnim,
          child: SlideTransition(
            position: _subtitleAnim.drive(Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
