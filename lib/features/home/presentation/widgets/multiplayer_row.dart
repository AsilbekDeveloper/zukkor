import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// "Create a room" (solid dark) / "Join with a code" (outlined) —
/// mirrors the prototype's `.mp-row`.
class MultiplayerRow extends StatelessWidget {
  const MultiplayerRow({
    required this.onCreateRoom,
    required this.onJoinWithCode,
    super.key,
  });

  final VoidCallback onCreateRoom;
  final VoidCallback onJoinWithCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MpButton(
            icon: TablerIcons.plus,
            label: context.t.home.createRoom,
            background: context.colors.surfaceDark,
            foreground: Colors.white,
            iconColor: Colors.white,
            border: null,
            onTap: onCreateRoom,
          ),
        ),
        AppSpacing.sm.hGap,
        Expanded(
          child: _MpButton(
            icon: TablerIcons.keyboard,
            label: context.t.home.joinWithCode,
            background: context.colors.card,
            foreground: context.colors.ink,
            iconColor: context.colors.coralDeep,
            border: Border.all(color: context.colors.line, width: 1.5),
            onTap: onJoinWithCode,
          ),
        ),
      ],
    );
  }
}

class _MpButton extends StatelessWidget {
  const _MpButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.iconColor,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color iconColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2, horizontal: AppSpacing.xs),
          decoration: BoxDecoration(borderRadius: AppRadius.smAll, border: border),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              // Shrinks instead of ellipsizing — this button is half the
              // row's width, and some locales' translation (e.g. Russian
              // "Присоединиться по коду") is much longer than English.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
