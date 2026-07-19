import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../theme/app_colors.dart';

/// The 5 avatar background colors used across the app — the onboarding
/// color picker, and the decorative avatars on things like the
/// leaderboard. `apiValue` matches the backend's `avatar_color` choices
/// exactly (Zukkor_Login.docx User model): 'a-coral' | 'a-teal' |
/// 'a-terra' | 'a-pink' | 'a-blue'.
enum AvatarColorOption {
  coral(apiValue: 'a-coral'),
  teal(apiValue: 'a-teal'),
  terra(apiValue: 'a-terra'),
  pink(apiValue: 'a-pink'),
  blue(apiValue: 'a-blue');

  const AvatarColorOption({required this.apiValue});

  final String apiValue;

  /// Matches the backend model's default so a freshly-started wizard
  /// already has a valid selection.
  static const AvatarColorOption fallback = AvatarColorOption.coral;

  /// Maps a backend `avatar_color` value back to the enum — used to
  /// preselect the current color when editing an existing profile.
  static AvatarColorOption fromApiValue(String? value) => AvatarColorOption.values
      .firstWhere((color) => color.apiValue == value, orElse: () => fallback);

  Color resolve(BuildContext context) {
    final AppColors colors = context.colors;
    return switch (this) {
      AvatarColorOption.coral => colors.coral,
      AvatarColorOption.teal => colors.teal,
      AvatarColorOption.terra => colors.terra,
      AvatarColorOption.pink => colors.pink,
      AvatarColorOption.blue => colors.blue,
    };
  }
}
