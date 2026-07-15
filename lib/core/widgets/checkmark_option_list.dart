import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../audio/app_sound.dart';
import '../audio/sound_controller.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// A single row in a [CheckmarkOptionList].
class CheckmarkOption {
  const CheckmarkOption({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
}

/// A card of single-select rows (icon + label + checkmark when active) —
/// mirrors the prototype's `.settings-list` used as a picker (Rank
/// Filter's category list, Language's language list). Group options into
/// separate [CheckmarkOptionList]s (with a gap between) when the
/// prototype shows them as visually distinct sections.
class CheckmarkOptionList extends StatelessWidget {
  const CheckmarkOptionList({required this.options, super.key});

  final List<CheckmarkOption> options;

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
          for (int i = 0; i < options.length; i++) ...[
            _CheckmarkOptionRow(option: options[i]),
            if (i < options.length - 1) Divider(height: 1, color: context.colors.line),
          ],
        ],
      ),
    );
  }
}

class _CheckmarkOptionRow extends ConsumerWidget {
  const _CheckmarkOptionRow({required this.option});

  final CheckmarkOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.playSound(AppSound.tap);
        option.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            Icon(option.icon, size: 19, color: context.colors.ink2),
            AppSpacing.sm.hGap,
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
            if (option.isActive) Icon(TablerIcons.check, size: 18, color: context.colors.coralDeep),
          ],
        ),
      ),
    );
  }
}
