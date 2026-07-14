import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../widgets/policy_content.dart';

/// Static Terms of Use copy.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  static const List<PolicySection> _sections = [
    PolicySection(title: AppStrings.termsSectionAccountTitle, body: AppStrings.termsSectionAccountBody),
    PolicySection(title: AppStrings.termsSectionConductTitle, body: AppStrings.termsSectionConductBody),
    PolicySection(title: AppStrings.termsSectionContentTitle, body: AppStrings.termsSectionContentBody),
    PolicySection(title: AppStrings.termsSectionChangesTitle, body: AppStrings.termsSectionChangesBody),
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
              BackHeader(title: AppStrings.termsOfUseTitle, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              const PolicyContent(sections: _sections),
            ],
          ),
        ),
      ),
    );
  }
}
