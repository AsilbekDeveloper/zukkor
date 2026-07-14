import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Zukkor brend belgisi — prototipdagi coral kvadrat ichida chaqmoq
/// ikonkasi + ilova nomi.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false});

  /// Kichik variant (appbar ichida ishlatish uchun).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double boxSize = compact ? 34 : 56;
    final double iconSize = compact ? 20 : 32;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.coral,
            borderRadius: BorderRadius.circular(compact ? 10 : AppRadius.sm),
            boxShadow: compact ? null : context.colors.shadowCoral,
          ),
          child: SizedBox.square(
            dimension: boxSize,
            child: Icon(TablerIcons.bolt, color: Colors.white, size: iconSize),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Flexible + ellipsis: on an extremely narrow width (split-screen,
        // landscape on a small device) the name shrinks instead of
        // overflowing the Row.
        Flexible(
          child: Text(
            AppStrings.appName,
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
