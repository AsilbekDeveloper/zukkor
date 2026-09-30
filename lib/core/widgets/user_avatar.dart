import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../config/app_config.dart';

/// A user's avatar — a real uploaded photo when [avatarImagePath] is set,
/// otherwise a neutral gray person-silhouette placeholder (Instagram-style,
/// 2026-09-30 foydalanuvchi so'rovi) instead of [initials]. Used everywhere
/// a real user's avatar appears (Home, Profile, Leaderboard, Friends) so a
/// photo or the same default shows up consistently across the app instead
/// of each screen drawing its own placeholder circle.
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
        _resolveUrl(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(context, radius),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(context, radius),
      ),
    );
  }

  /// Backend may return either an absolute URL or a path relative to the
  /// API root (e.g. `/uploads/avatars/xyz.jpg`) — `Image.network` needs a
  /// full URL either way, so a relative path gets [AppConfig.apiBaseUrl]
  /// prepended.
  static String _resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return path.startsWith('/') ? '${AppConfig.apiBaseUrl}$path' : '${AppConfig.apiBaseUrl}/$path';
  }

  static const Color _silhouetteBackground = Color(0xFFDBDBDB);
  static const Color _silhouetteIcon = Color(0xFFAFAFAF);

  Widget _fallback(BuildContext context, BorderRadius radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: gradient == null ? _silhouetteBackground : null,
        gradient: gradient,
      ),
      alignment: Alignment.center,
      child: Icon(
        TablerIcons.userFilled,
        size: size * 0.62,
        color: _silhouetteIcon,
      ),
    );
  }
}
