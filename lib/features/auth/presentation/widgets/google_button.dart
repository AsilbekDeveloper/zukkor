import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_button.dart';

/// "Google bilan davom etish" tugmasi — ikkilamchi (karta fonli) uslubda,
/// rangli "G" belgisi bilan.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed, this.enabled = true});

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppButton.secondary(
      label: AppStrings.continueWithGoogle,
      onPressed: enabled ? onPressed : null,
      icon: _GoogleGlyph(color: context.colors.blue),
    );
  }
}

/// Sodda "G" belgisi. (Rasmiy Google logotipi asset sifatida keyin
/// qo'shilishi mumkin; hozircha brendga ishora yetarli.)
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.line, width: 1.5),
      ),
      child: Text(
        'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
          height: 1,
        ),
      ),
    );
  }
}
