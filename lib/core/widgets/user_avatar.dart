import 'package:flutter/material.dart';

import '../extensions/context_x.dart';

/// A user's avatar — a real uploaded photo when [avatarImagePath] is set,
/// otherwise a colored circle (or [gradient]) with [initials]. Used
/// everywhere a real user's avatar appears (Home, Profile, Leaderboard,
/// Friends) so a photo or color choice shows up consistently across the
/// app instead of each screen drawing its own placeholder circle.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.size,
    required this.initials,
    this.avatarImagePath,
    this.backgroundColor,
    this.gradient,
    this.fontSize,
    this.borderRadius,
    super.key,
  });

  final double size;
  final String initials;
  final String? avatarImagePath;

  /// Fallback background when there's no photo. Ignored when [gradient]
  /// is set. Defaults to [AppColors.coral] if neither is given.
  final Color? backgroundColor;

  /// Fallback background gradient (e.g. the leaderboard podium's gold
  /// 1st-place styling) — takes precedence over [backgroundColor], and
  /// only applies when there's no photo.
  final Gradient? gradient;

  final double? fontSize;

  /// Shape of the avatar — defaults to a full circle. Pass a smaller
  /// radius (e.g. [AppRadius.smAll]) for screens that use a rounded
  /// square instead (like the Home header).
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? BorderRadius.circular(size / 2);
    final String? path = avatarImagePath;
    if (path == null) return _fallback(context, radius);

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context, radius),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(context, radius),
      ),
    );
  }

  Widget _fallback(BuildContext context, BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: gradient == null ? (backgroundColor ?? context.colors.coral) : null,
        gradient: gradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? size * 0.32,
          color: Colors.white,
        ),
      ),
    );
  }
}
