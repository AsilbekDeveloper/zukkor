import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// A single failed section's fallback — unlike [ErrorRetryView] (which
/// replaces an entire screen), this is a compact row meant to sit in
/// place of just one piece of a larger screen (e.g. Home's stats strip),
/// so the rest of that screen's content stays visible and usable even
/// when this one section couldn't load.
class InlineRetryRow extends StatelessWidget {
  const InlineRetryRow({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          Icon(TablerIcons.alertTriangle, size: 18, color: context.colors.muted),
          AppSpacing.sm.hGap,
          Expanded(
            child: Text(
              context.t.errors.unknown,
              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.t.common.retry)),
        ],
      ),
    );
  }
}
