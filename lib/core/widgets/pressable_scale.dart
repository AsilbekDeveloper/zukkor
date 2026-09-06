import 'package:flutter/material.dart';

/// Wraps an already-tappable child (its own Material/InkWell still
/// handles the actual tap and ripple) with a subtle "press" scale-down
/// while a finger is down on it - uses [Listener], which only OBSERVES
/// pointer events rather than competing with the child's own gesture
/// handling, so nothing about the wrapped widget's tap behavior changes.
class PressableScale extends StatefulWidget {
  const PressableScale({required this.child, this.scale = 0.96, super.key});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
