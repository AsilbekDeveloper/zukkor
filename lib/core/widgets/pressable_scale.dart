import 'package:flutter/material.dart';

/// Wraps an already-tappable child (its own Material/InkWell still
/// handles the actual tap and ripple) with a subtle "press" scale-down
/// while a finger is down on it - uses [Listener], which only OBSERVES
/// pointer events rather than competing with the child's own gesture
/// handling, so nothing about the wrapped widget's tap behavior changes.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.scale = 0.96,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final double scale;

  /// False for an already-disabled child (e.g. an answer button after
  /// the question has been answered) - without this, a stray tap on a
  /// disabled button would still visually "press" even though nothing
  /// happens, which reads as broken rather than disabled.
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled
          ? (_) => setState(() => _pressed = true)
          : null,
      onPointerUp: widget.enabled
          ? (_) => setState(() => _pressed = false)
          : null,
      onPointerCancel: widget.enabled
          ? (_) => setState(() => _pressed = false)
          : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
