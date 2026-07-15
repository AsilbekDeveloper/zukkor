import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../audio/app_sound.dart';
import '../audio/sound_controller.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// Close (X) button + centered title — mirrors the prototype's modal-like
/// sub-screen `.header` pattern (Player Detail, Duel Waiting, Duel
/// Invite), where the leading action cancels/dismisses instead of going
/// back a step.
class CloseHeader extends StatelessWidget {
  const CloseHeader({required this.title, required this.onClose, super.key});

  final String title;
  final VoidCallback onClose;

  // A same-width invisible spacer balances the leading icon button so the
  // title sits truly centered — matches the prototype's header
  // (`<span style="width:44px">` after the title).
  static const double _iconButtonSize = 44;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CloseIconButton(onTap: onClose),
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

class _CloseIconButton extends ConsumerWidget {
  const _CloseIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: () {
          ref.playSound(AppSound.tap);
          onTap();
        },
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(TablerIcons.x, color: context.colors.ink, size: 20),
        ),
      ),
    );
  }
}
