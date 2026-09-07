import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../models/friend_request_entry.dart';

/// Incoming friend-request rows with Accept/Decline actions — mirrors
/// [FriendList]'s row layout, swapping the single duel button for a pair
/// of decision buttons.
class FriendRequestList extends StatelessWidget {
  const FriendRequestList({
    required this.entries,
    required this.onAcceptTap,
    required this.onDeclineTap,
    required this.onRowTap,
    this.processingIds = const {},
    super.key,
  });

  final List<FriendRequestEntry> entries;
  final ValueChanged<FriendRequestEntry> onAcceptTap;
  final ValueChanged<FriendRequestEntry> onDeclineTap;
  final ValueChanged<FriendRequestEntry> onRowTap;

  /// Requests whose accept/decline is currently in flight — both action
  /// buttons on that row disable (and the busy one shows a spinner)
  /// instead of allowing a fast double-tap to fire the request twice.
  final Set<String> processingIds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _RequestRow(
            entry: entries[i],
            isProcessing: processingIds.contains(entries[i].id),
            onAcceptTap: () => onAcceptTap(entries[i]),
            onDeclineTap: () => onDeclineTap(entries[i]),
            onRowTap: () => onRowTap(entries[i]),
          ),
          if (i < entries.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.entry,
    required this.isProcessing,
    required this.onAcceptTap,
    required this.onDeclineTap,
    required this.onRowTap,
  });

  final FriendRequestEntry entry;
  final bool isProcessing;
  final VoidCallback onAcceptTap;
  final VoidCallback onDeclineTap;
  final VoidCallback onRowTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onRowTap();
          },
          borderRadius: AppRadius.smAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 1,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(color: context.colors.line),
              boxShadow: context.colors.shadowSm,
            ),
            child: Row(
              children: [
                UserAvatar(
                  size: 36,
                  initials: entry.initials,
                  avatarImagePath: entry.avatarImagePath,
                  backgroundColor: entry.avatarColor.resolve(context),
                  fontSize: 11.5,
                ),
                AppSpacing.sm.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                      if (entry.handle != null)
                        Text(
                          entry.handle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelSmall?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                AppSpacing.sm.hGap,
                _ActionButton(
                  icon: TablerIcons.x,
                  onTap: onDeclineTap,
                  isPrimary: false,
                  isBusy: isProcessing,
                  enabled: !isProcessing,
                ),
                AppSpacing.xs.hGap,
                _ActionButton(
                  icon: TablerIcons.check,
                  onTap: onAcceptTap,
                  isPrimary: true,
                  isBusy: isProcessing,
                  enabled: !isProcessing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    required this.isBusy,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  /// True only while THIS button's own action is in flight — the other
  /// button on the row is [enabled]: false too, but shows the plain
  /// icon rather than a spinner, since it isn't the one running.
  final bool isBusy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(11);
    final Color spinnerColor = isPrimary ? Colors.white : context.colors.coral;
    final Widget glyph = isBusy
        ? SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        : Icon(
            icon,
            size: 16,
            color: isPrimary ? Colors.white : context.colors.coral,
          );

    final VoidCallback? effectiveOnTap = enabled
        ? () {
            HapticFeedback.lightImpact();
            onTap();
          }
        : null;

    if (isPrimary) {
      return PressableScale(
        enabled: enabled,
        child: Material(
          color: context.colors.teal,
          borderRadius: radius,
          child: InkWell(
            onTap: effectiveOnTap,
            borderRadius: radius,
            child: SizedBox(width: 36, height: 36, child: Center(child: glyph)),
          ),
        ),
      );
    }
    return PressableScale(
      enabled: enabled,
      child: Material(
        color: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: context.colors.line),
        ),
        child: InkWell(
          onTap: effectiveOnTap,
          borderRadius: radius,
          child: SizedBox(width: 36, height: 36, child: Center(child: glyph)),
        ),
      ),
    );
  }
}
