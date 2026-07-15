import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// The coral gradient banner with an overlapping avatar circle — mirrors
/// the prototype's `.profile-banner` / `.profile-avatar-wrap`.
class ProfileBanner extends StatelessWidget {
  const ProfileBanner({required this.initials, required this.onEditTap, super.key});

  final String initials;
  final VoidCallback onEditTap;

  static const double _bannerHeight = 92;
  static const double _avatarSize = 72;
  // Half the avatar overhangs below the banner (matches the prototype's
  // `bottom: -32px` on `.profile-avatar-wrap`) — the extra space is
  // reserved so the next section doesn't collide with it.
  static const double _avatarOverhang = 32;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _avatarOverhang + AppSpacing.xs),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: _bannerHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF7A50),
                  context.colors.coral,
                  context.colors.coralDeep,
                ],
                stops: const [0, 0.45, 1],
              ),
              boxShadow: context.colors.shadowCoral,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -70,
                  right: -40,
                  child: _decoCircle(150, Colors.white.withValues(alpha: 0.14)),
                ),
                Positioned(
                  bottom: -60,
                  left: -30,
                  child: _decoCircle(100, Colors.white.withValues(alpha: 0.09)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _EditButton(onTap: onEditTap),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -_avatarOverhang,
            child: Center(
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: context.colors.cream, width: 4),
                  boxShadow: context.colors.shadowMd,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                    color: context.colors.coralDeep,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decoCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            TablerIcons.pencil,
            color: context.colors.coralDeep,
            size: 20,
            semanticLabel: context.t.profile.editProfile,
          ),
        ),
      ),
    );
  }
}
