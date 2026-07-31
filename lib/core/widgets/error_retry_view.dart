import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Shown in place of a screen's content when its initial load fails —
/// replaces the old behavior of silently leaving the screen stuck on its
/// loading skeleton forever, indistinguishable from "still loading".
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.alertTriangle, size: 32, color: context.colors.muted),
            AppSpacing.sm.vGap,
            Text(
              context.t.errors.unknown,
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
            ),
            AppSpacing.md.vGap,
            AppButton.secondary(label: context.t.common.retry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
