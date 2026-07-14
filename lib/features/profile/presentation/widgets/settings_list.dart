import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// A card of tappable rows (icon + label + chevron) — mirrors the
/// prototype's `.settings-list` / `.settings-row`.
class SettingsList extends StatelessWidget {
  const SettingsList({required this.rows, super.key});

  final List<SettingsRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _SettingsRow(data: rows[i]),
            if (i < rows.length - 1) Divider(height: 1, color: context.colors.line),
          ],
        ],
      ),
    );
  }
}

class SettingsRowData {
  const SettingsRowData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingLabel,
    this.trailingWidget,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// A muted value shown before the trailing icon/widget, e.g. "English"
  /// on a Language row — mirrors the prototype's `.settings-row b`.
  final String? trailingLabel;

  /// Replaces the default chevron when set (e.g. a theme switch). Pass
  /// [SizedBox.shrink] to show nothing (the danger/Log out row has no
  /// trailing element at all in the prototype).
  final Widget? trailingWidget;

  /// Coral icon/label + no chevron by default — mirrors `.settings-row.danger`.
  final bool isDanger;
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final SettingsRowData data;

  @override
  Widget build(BuildContext context) {
    final Color? dangerColor = data.isDanger ? context.colors.coralDeep : null;
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            Icon(data.icon, size: 19, color: dangerColor ?? context.colors.ink2),
            AppSpacing.sm.hGap,
            Expanded(
              child: Text(
                data.label,
                style: context.textStyles.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: dangerColor,
                ),
              ),
            ),
            if (data.trailingLabel != null) ...[
              Text(
                data.trailingLabel!,
                style: context.textStyles.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              AppSpacing.xs.hGap,
            ],
            data.trailingWidget ?? Icon(TablerIcons.chevronRight, size: 17, color: context.colors.muted),
          ],
        ),
      ),
    );
  }
}
