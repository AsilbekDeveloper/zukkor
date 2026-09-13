import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// A slim banner for a live game screen (Duel/Lobby) — used both for
/// this device's own WebSocket dropping (the underlying socket data
/// sources already track `isConnected` and retry on their own, but
/// nothing ever showed the user that anything was happening) and, for
/// Duel specifically, for the OPPONENT's connection dropping during
/// their reconnect grace window (2026-09-13, found/added ahead of the
/// first real-device test pass). Renders nothing while [visible] is
/// false, so callers can drop it in unconditionally.
class ReconnectingBanner extends StatelessWidget {
  const ReconnectingBanner({required this.visible, this.message, super.key});

  final bool visible;

  /// Defaults to the generic "Reconnecting…" copy (this device's own
  /// connection); pass an explicit message for a different case, e.g.
  /// the opponent's connection dropping.
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        color: context.colors.error,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            AppSpacing.xs.hGap,
            Text(
              message ?? context.t.common.reconnecting,
              style: context.textStyles.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
