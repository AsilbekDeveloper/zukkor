import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/app_sound.dart';
import '../audio/sound_controller.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// A pill-shaped, N-way segmented control — mirrors the prototype's
/// `.segment` / `.seg-btn`. Generic over any value type so both the
/// Leaderboard's 3-way segment and Game History's 4-way filter share one
/// implementation.
class PillSegmentControl<T> extends ConsumerWidget {
  const PillSegmentControl({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          for (final T value in values)
            Expanded(
              child: _SegmentButton(
                label: labelBuilder(value),
                isActive: value == selected,
                onTap: () {
                  ref.playSound(AppSound.tap);
                  onChanged(value);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? context.colors.surfaceDark : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm - 1),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : context.colors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
