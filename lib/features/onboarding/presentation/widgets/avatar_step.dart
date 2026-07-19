import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/avatar_color_picker.dart';
import '../../../../core/widgets/step_header.dart';
import '../../../../i18n/strings.g.dart';

/// Onboarding step 1 — pick an avatar background color (photo upload is a
/// stub for now, see [onUploadPhoto]).
class AvatarStep extends StatelessWidget {
  const AvatarStep({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.onUploadPhoto,
  });

  final AvatarColorOption selectedColor;
  final ValueChanged<AvatarColorOption> onColorSelected;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          icon: TablerIcons.sparkles,
          title: context.t.onboarding.avatarTitle,
          subtitle: context.t.onboarding.avatarSubtitle,
        ),
        AppSpacing.xxl.vGap,
        AvatarColorPicker(
          selectedColor: selectedColor,
          onColorSelected: onColorSelected,
          onUploadPhoto: onUploadPhoto,
        ),
      ],
    );
  }
}
