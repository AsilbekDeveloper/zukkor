import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A short, one-shot particle burst — purely decorative, celebrates
/// finishing the Introduction walkthrough. Calls [onDone] once every
/// particle has finished fading out.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.colors, required this.onDone});

  final List<Color> colors;
  final VoidCallback onDone;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _Particle {
  _Particle({required this.color, required this.angle, required this.speed, required this.size});

  final Color color;
  final double angle;
  final double speed;
  final double size;
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final List<_Particle> _particles = _generateParticles();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _controller.forward();
  }

  List<_Particle> _generateParticles() {
    final math.Random random = math.Random();
    return List.generate(28, (_) {
      return _Particle(
        color: widget.colors[random.nextInt(widget.colors.length)],
        angle: random.nextDouble() * 2 * math.pi,
        speed: 120 + random.nextDouble() * 140,
        size: 5 + random.nextDouble() * 5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(particles: _particles, progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.35);
    final Paint paint = Paint();
    for (final _Particle particle in particles) {
      final double distance = particle.speed * progress;
      final double gravity = 260 * progress * progress;
      final Offset position = center +
          Offset(
            math.cos(particle.angle) * distance,
            math.sin(particle.angle) * distance + gravity,
          );
      final double opacity = (1 - progress).clamp(0, 1);
      paint.color = particle.color.withValues(alpha: opacity);
      canvas.drawCircle(position, particle.size * (1 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
