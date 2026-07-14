import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// Back button + centered title — mirrors the prototype's sub-screen
/// `.header` pattern (Categories, Add Friend, 1v1 Duel, ...).
class BackHeader extends StatelessWidget {
  const BackHeader({required this.title, required this.onBack, super.key});

  final String title;
  final VoidCallback onBack;

  // A same-width invisible spacer balances the leading icon button so the
  // title sits truly centered — matches the prototype's header
  // (`<span style="width:44px">` after the title).
  static const double _iconButtonSize = 44;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BackIconButton(onTap: onBack),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.titleLarge,
          ),
        ),
        const SizedBox(width: _iconButtonSize),
      ],
    );
  }
}

class _BackIconButton extends StatelessWidget {
  const _BackIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(TablerIcons.arrowLeft, color: context.colors.ink, size: 20),
        ),
      ),
    );
  }
}
