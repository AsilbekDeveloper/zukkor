import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';

/// Ekran pastidagi "X? Y" qatori — Login'da Register'ga, Register'da
/// Login'ga o'tish havolasi.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            promptText,
            style: context.textStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onTap, child: Text(actionText)),
      ],
    );
  }
}
