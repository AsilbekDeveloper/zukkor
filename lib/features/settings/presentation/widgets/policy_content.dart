import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// One heading + paragraph block in a [PolicyContent].
class PolicySection {
  const PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}

/// A scrollable stack of heading+paragraph blocks — shared by the
/// Privacy Policy and Terms of Use screens, which are structurally
/// identical (just different copy).
class PolicyContent extends StatelessWidget {
  const PolicyContent({required this.sections, super.key});

  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          Text(
            sections[i].title,
            style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            sections[i].body,
            style: context.textStyles.bodySmall?.copyWith(color: context.colors.ink2, height: 1.6),
          ),
          if (i < sections.length - 1) AppSpacing.lg.vGap,
        ],
      ],
    );
  }
}
