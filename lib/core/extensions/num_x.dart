import 'package:flutter/widgets.dart';

/// Bo'shliq yordamchilari: `AppSpacing.md.vGap` — Column ichida vertikal
/// bo'shliq. SizedBox'dan ko'ra o'qilishi osonroq, xatoga kam moyil.
extension SpacingX on num {
  SizedBox get vGap => SizedBox(height: toDouble());
  SizedBox get hGap => SizedBox(width: toDouble());
}
