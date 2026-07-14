import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/game_history_entry.dart';

/// A column of past-game rows — mirrors the prototype's `.history-list` /
/// `.history-row`. Rows are informational only (no tap target in the
/// prototype).
class HistoryList extends StatelessWidget {
  const HistoryList({required this.entries, super.key});

  final List<GameHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _HistoryRow(entry: entries[i]),
          if (i < entries.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final GameHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: AppRadius.smAll,
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: entry.category.color(context),
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(entry.category.icon, color: Colors.white, size: 19),
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                Text(
                  entry.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelSmall,
                ),
              ],
            ),
          ),
          AppSpacing.sm.hGap,
          if (entry.isWinBadge == null)
            Text(
              entry.resultText,
              style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            )
          else
            _ResultBadge(isWin: entry.isWinBadge!, label: entry.resultText),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.isWin, required this.label});

  final bool isWin;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm - 2, vertical: AppSpacing.xxs + 1),
      decoration: BoxDecoration(
        color: isWin ? context.colors.green : context.colors.coral,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
