import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// "Profile" title + settings icon button — mirrors the prototype's
/// `view-profile` `.header`.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.onSettingsTap, super.key});

  final VoidCallback onSettingsTap;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onSettingsTap();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.bottomNav.profile,
            style: context.textStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PressableScale(
          child: Material(
            color: context.colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
              side: BorderSide(color: context.colors.line),
            ),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: AppRadius.smAll,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  TablerIcons.settings,
                  color: context.colors.ink,
                  size: 20,
                  semanticLabel: context.t.profile.settings,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
