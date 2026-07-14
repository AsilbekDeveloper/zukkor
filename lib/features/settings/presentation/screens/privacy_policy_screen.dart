import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../widgets/policy_content.dart';

/// Static Privacy Policy copy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<PolicySection> _sections = [
    PolicySection(
      title: AppStrings.privacySectionCollectionTitle,
      body: AppStrings.privacySectionCollectionBody,
    ),
    PolicySection(title: AppStrings.privacySectionUseTitle, body: AppStrings.privacySectionUseBody),
    PolicySection(
      title: AppStrings.privacySectionSharingTitle,
      body: AppStrings.privacySectionSharingBody,
    ),
    PolicySection(
      title: AppStrings.privacySectionContactTitle,
      body: AppStrings.privacySectionContactBody,
    ),
  ];

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: AppStrings.privacyPolicyTitle, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              const PolicyContent(sections: _sections),
            ],
          ),
        ),
      ),
    );
  }
}
