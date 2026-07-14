import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

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
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Icon(TablerIcons.search, color: context.colors.muted, size: 18),
          AppSpacing.sm.hGap,
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: context.textStyles.bodySmall?.copyWith(color: context.colors.ink),
              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintMaxLines: 1,
                hintStyle: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: _clear,
              borderRadius: AppRadius.smAll,
              child: Icon(TablerIcons.x, color: context.colors.muted, size: 16),
            ),
        ],
      ),
    );
  }
}
