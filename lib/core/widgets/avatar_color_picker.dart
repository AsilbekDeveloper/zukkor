import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../i18n/strings.g.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../models/avatar_color_option.dart';
import '../theme/app_spacing.dart';
import 'user_avatar.dart';

/// Avatar circle + upload button + 5-color swatch row — shared between
/// Onboarding's avatar step and Edit Profile. Shows the real uploaded
/// photo when [avatarImagePath] is set (only ever non-null in Edit
/// Profile — Onboarding hasn't uploaded anything yet).
class AvatarColorPicker extends StatelessWidget {
  const AvatarColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onUploadPhoto,
    this.avatarImagePath,
  });

  final AvatarColorOption selectedColor;
  final String? avatarImagePath;
  final ValueChanged<AvatarColorOption> onColorSelected;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatarImagePath != null
                  ? UserAvatar(size: 112, initials: '', avatarImagePath: avatarImagePath)
                  : CircleAvatar(
                      radius: 56,
                      backgroundColor: selectedColor.resolve(context),
                      child: const Icon(TablerIcons.user, color: Colors.white, size: 56),
                    ),
              Positioned(
                right: -4,
                bottom: -4,
                child: _UploadButton(onTap: onUploadPhoto),
              ),
            ],
          ),
        ),
        AppSpacing.xxl.vGap,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final AvatarColorOption color in AvatarColorOption.values)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _ColorSwatch(
                  color: color,
                  isSelected: color == selectedColor,
                  onTap: () => onColorSelected(color),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: CircleBorder(side: BorderSide(color: context.colors.line, width: 2)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(
            TablerIcons.camera,
            size: 20,
            color: context.colors.ink,
            semanticLabel: context.t.onboarding.uploadPhoto,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final AvatarColorOption color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color resolved = color.resolve(context);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: resolved,
          border: Border.all(
            color: isSelected ? context.colors.ink : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: resolved.withValues(alpha: 0.4), blurRadius: 8)]
              : null,
        ),
        alignment: Alignment.center,
        // Bare check glyph (matches the prototype's ti-check) on a circle
        // we already draw ourselves — the swatch color IS the content.
        child: isSelected
            ? const Icon(TablerIcons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
