import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/app_sound.dart';
import '../audio/sound_controller.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

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
    this.enabled = true,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  /// False while switching segments doesn't make sense right now (e.g.
  /// a generation in progress) - without this, callers used to pass a
  /// no-op `onChanged` instead, which left the segments still visually
  /// pressing and buzzing on tap even though nothing happened. Mirrors
  /// [PressableScale.enabled]/[AnswerButton]'s `enabled` convention.
  final bool enabled;

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
                enabled: enabled,
                onTap: () {
                  ref.playSound(AppSound.tap);
                  HapticFeedback.lightImpact();
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
    required this.enabled,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      enabled: enabled,
      child: Material(
        color: isActive ? context.colors.surfaceDark : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm - 1,
              horizontal: AppSpacing.xxs,
            ),
            // Shrinks instead of ellipsizing — each segment is a narrow
            // fraction of the pill's width, and some locales' label is
            // longer than others (e.g. History's 4-way filter).
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: context.textStyles.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : context.colors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
