import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

class ShareLinkButton extends StatelessWidget {
  const ShareLinkButton({required this.onTap, super.key});

  final VoidCallback onTap;

  // rgba(33,20,16,.22), matching the prototype's `.mp-btn.dark` box-shadow.
  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x38211410), offset: Offset(0, 10), blurRadius: 22),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: const BoxDecoration(borderRadius: AppRadius.smAll, boxShadow: _shadow),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TablerIcons.share3, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                context.t.addFriend.shareLink,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
