import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
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
    super.key,
  });

  final List<FriendRequestEntry> entries;
  final ValueChanged<FriendRequestEntry> onAcceptTap;
  final ValueChanged<FriendRequestEntry> onDeclineTap;
  final ValueChanged<FriendRequestEntry> onRowTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _RequestRow(
            entry: entries[i],
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
    required this.onAcceptTap,
    required this.onDeclineTap,
    required this.onRowTap,
  });

  final FriendRequestEntry entry;
  final VoidCallback onAcceptTap;
  final VoidCallback onDeclineTap;
  final VoidCallback onRowTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onRowTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
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
                      style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    if (entry.handle != null)
                      Text(
                        entry.handle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                      ),
                  ],
                ),
              ),
              AppSpacing.sm.hGap,
              _ActionButton(icon: TablerIcons.x, onTap: onDeclineTap, isPrimary: false),
              AppSpacing.xs.hGap,
              _ActionButton(icon: TablerIcons.check, onTap: onAcceptTap, isPrimary: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap, required this.isPrimary});

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(11);
    final Widget glyph = Icon(icon, size: 16, color: isPrimary ? Colors.white : context.colors.coral);

    if (isPrimary) {
      return Material(
        color: context.colors.teal,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(width: 36, height: 36, child: Center(child: glyph)),
        ),
      );
    }
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: context.colors.line)),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(width: 36, height: 36, child: Center(child: glyph)),
      ),
    );
  }
}
