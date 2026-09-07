import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';

/// A real search field — mirrors the prototype's `.search-bar`. Reused by
/// both the Friends list ("Search friends") and Add Friend ("Search by
/// username") screens; the caller owns [controller] and filters its own
/// list from [onChanged].
class FriendsSearchBar extends StatelessWidget {
  const FriendsSearchBar({
    required this.placeholder,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _clear() {
    HapticFeedback.lightImpact();
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    // A fixed height - a standard, compact search-bar size (matches a
    // default Material text field) regardless of font-metric rounding,
    // rather than one derived from padding + line-height math.
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(TablerIcons.search, color: context.colors.muted, size: 18),
          AppSpacing.sm.hGap,
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.ink,
              ),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                filled: false,
                // The app's global InputDecorationTheme sets its OWN
                // enabledBorder/focusedBorder (a full outline) - setting
                // only `border` above doesn't override those, so a second,
                // inner outline was leaking through around this field even
                // though the surrounding Container already draws the one
                // real border. Every state must be silenced explicitly.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: placeholder,
                hintMaxLines: 1,
                hintStyle: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            PressableScale(
              child: InkWell(
                onTap: _clear,
                borderRadius: AppRadius.smAll,
                child: Icon(
                  TablerIcons.x,
                  color: context.colors.muted,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
