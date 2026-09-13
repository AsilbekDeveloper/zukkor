import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// A slim banner for a live game screen (Duel/Lobby) whose WebSocket has
/// dropped — without this, a lost connection looked identical to the
/// game just hanging: the underlying socket data sources already track
/// `isConnected` and retry on their own, but nothing ever showed the
/// user that anything was happening (2026-09-13, found ahead of the
/// first real-device test pass). Renders nothing when connected, so
/// callers can drop it in unconditionally.
class ReconnectingBanner extends StatelessWidget {
  const ReconnectingBanner({required this.isConnected, super.key});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

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
              context.t.common.reconnecting,
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
