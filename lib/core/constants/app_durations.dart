import 'package:flutter/animation.dart';

/// Animatsiya vaqtlari va egri chizig'i — prototipdagi
/// `--ease: cubic-bezier(0.22, 1, 0.36, 1)` ga mos.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Prototipdagi asosiy easing — "chiqishda sekinlashadigan" tabiiy harakat.
  static const Curve ease = Cubic(0.22, 1, 0.36, 1);
}
