import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/notification_entry.dart';

/// A column of notification rows — mirrors the prototype's `.notif-list`
/// / `.notif-row`. Unread rows are marked by a small coral dot.
class NotificationList extends StatelessWidget {
  const NotificationList({required this.entries, required this.onEntryTap, super.key});

  final List<NotificationEntry> entries;
  final ValueChanged<NotificationEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _NotificationRow(entry: entries[i], onTap: () => onEntryTap(entries[i])),
          if (i < entries.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.entry, required this.onTap});

  final NotificationEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: context.colors.line),
            boxShadow: context.colors.shadowSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: entry.colorKey.resolve(context),
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(entry.icon, color: Colors.white, size: 19),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title(context),
                      style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
                    ),
                    Text(entry.timeLabel, style: context.textStyles.labelSmall),
                  ],
                ),
              ),
              if (entry.isUnread) ...[
                AppSpacing.sm.hGap,
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.coral),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
