import 'package:flutter/material.dart';

import '../constants/app_durations.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary }

/// Ilovaning asosiy tugmasi — prototipdagi `.hero-play.full` (coral) va
/// `.mp-btn.light` (karta fonli) uslublari.
///
///  - [isLoading] paytida tugma bosilmaydi va spinner ko'rsatiladi,
///    LEKIN o'lchami o'zgarmaydi (layout sakramaydi).
///  - Primary variantda prototipdagi coral soya bor.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  bool get _isPrimary => variant == AppButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    final Widget child = AnimatedSwitcher(
      duration: AppDurations.fast,
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _isPrimary ? Colors.white : context.colors.ink,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpacing.xs),
                ],
                // Katta shrift masshtabida ham bir qatorda sig'adi.
                Flexible(
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
    );

    final Widget button = _isPrimary
        ? ElevatedButton(onPressed: effectiveOnPressed, child: child)
        : OutlinedButton(onPressed: effectiveOnPressed, child: child);

    // Coral soya faqat faol primary tugmada — o'chirilgan holatda
    // "yonib turgan" soya g'alati ko'rinadi.
    if (_isPrimary && effectiveOnPressed != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.smAll,
          boxShadow: context.colors.shadowCoral,
        ),
        child: button,
      );
    }
    return button;
  }
}
