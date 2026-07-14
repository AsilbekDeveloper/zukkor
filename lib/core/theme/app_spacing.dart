import 'package:flutter/widgets.dart';

/// Bo'shliqlar shkalasi — butun ilova bo'ylab faqat shu qiymatlar ishlatiladi,
/// "ko'zga qarab" tanlangan tasodifiy paddinglar bo'lmaydi.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Ekran chetidagi standart gorizontal padding (prototipdagi 20px).
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);
}

/// Burchak radiuslari — prototipdagi --r-sm/--r-md/--r-lg.
abstract final class AppRadius {
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 26;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
}
