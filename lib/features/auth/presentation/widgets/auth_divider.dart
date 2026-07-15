import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// "yoki" ajratgichi — email/parol formasi bilan Google tugmasi orasida.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(context.t.auth.orDivider, style: context.textStyles.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
