import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Dark card showing overlapping avatars of online friends + a "duel"
/// shortcut — mirrors the prototype's `.friends`.
class FriendsOnlineCard extends StatelessWidget {
  const FriendsOnlineCard({
    required this.onlineCount,
    required this.onTap,
    super.key,
  });

  final int onlineCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Matches the prototype's mini avatar palette: coral, teal, terra.
    final List<Color> avatarColors = [
      context.colors.coral,
      context.colors.teal,
      context.colors.terra,
    ];

    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              SizedBox(
                width: 34 + (avatarColors.length - 1) * 24,
                height: 34,
                child: Stack(
                  children: [
                    for (int i = 0; i < avatarColors.length; i++)
                      Positioned(
                        left: i * 24.0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avatarColors[i],
                            border: Border.all(color: context.colors.surfaceDark, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.xs.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t.common.friendsOnline(count: onlineCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.t.home.challengeToDuel,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.swords, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
