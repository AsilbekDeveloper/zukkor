import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

/// The dark "big code" card — mirrors the prototype's `.room-card`.
/// Shared by the Add Friend screen ("Your invite code") and the Lobby
/// screen ("Room code") — same visuals, different [label]. Tapping
/// copies [code] to the clipboard - added 2026-09-06 (previously this
/// card wasn't tappable at all, so sharing the code meant reading it
/// off-screen and retyping it by hand; [CompactInviteCard] already had
/// its own copy-to-clipboard, this brings the same behavior here).
class InviteCodeCard extends StatelessWidget {
  const InviteCodeCard({required this.label, required this.code, super.key});

  final String label;
  final String code;

  // rgba(33,20,16,.22), matching the prototype's `.room-card` box-shadow —
  // a one-off, heavier than any of the shared AppColors shadow tiers.
  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x38211410), offset: Offset(0, 14), blurRadius: 30),
  ];

  Future<void> _copyCode(BuildContext context) async {
    unawaited(HapticFeedback.lightImpact());
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) context.showSnack(context.t.common.codeCopied);
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.surfaceDark,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: () => _copyCode(context),
          borderRadius: AppRadius.lgAll,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              borderRadius: AppRadius.lgAll,
              boxShadow: _shadow,
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                // FittedBox.scaleDown: stays 28px whenever it fits, and
                // shrinks uniformly on very narrow screens instead of
                // overflowing.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        TablerIcons.copy,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
