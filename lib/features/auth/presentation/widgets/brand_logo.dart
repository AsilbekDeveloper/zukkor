import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Zukkor brend belgisi — "Z" belgisi (orange diagonal + ikkita gorizontal
/// chiziq) to'g'ridan-to'g'ri ekran foniga chiziladi (o'ziga xos rangli
/// quti yo'q). Chiziqlar rangi joriy mavzuga moslashadi — och mavzuda
/// quyuq, quyuq mavzuda och — orange diagonal esa har doim bir xil qoladi.
/// Ilova belgisi (launcher icon) esa har doim quyuq fonli statik versiya
/// (do'kon/telefon shaffof fonni qo'llab-quvvatlamaydi, [pubspec.yaml]dagi
/// `flutter_launcher_icons` konfiguratsiyasiga qarang).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false});

  /// Kichik variant (appbar ichida ishlatish uchun).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double boxSize = compact ? 34 : 56;
    final String markAsset = context.isDark
        ? 'assets/branding/zukkor_mark_on_dark.png'
        : 'assets/branding/zukkor_mark_on_light.png';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: boxSize,
          child: Image.asset(markAsset),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Flexible + ellipsis: on an extremely narrow width (split-screen,
        // landscape on a small device) the name shrinks instead of
        // overflowing the Row.
        Flexible(
          child: Text(
            context.t.common.appName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? context.textStyles.titleLarge
                    : context.textStyles.headlineMedium)
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
