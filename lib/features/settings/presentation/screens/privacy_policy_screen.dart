import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../widgets/policy_content.dart';

/// Static Privacy Policy copy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  List<PolicySection> _sections(BuildContext context) => [
        PolicySection(
          title: context.t.privacyPolicy.collectionTitle,
          body: context.t.privacyPolicy.collectionBody,
        ),
        PolicySection(title: context.t.privacyPolicy.useTitle, body: context.t.privacyPolicy.useBody),
        PolicySection(
          title: context.t.privacyPolicy.sharingTitle,
          body: context.t.privacyPolicy.sharingBody,
        ),
        PolicySection(
          title: context.t.privacyPolicy.contactTitle,
          body: context.t.privacyPolicy.contactBody,
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
              BackHeader(title: context.t.privacyPolicy.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              PolicyContent(sections: _sections(context)),
            ],
          ),
        ),
      ),
    );
  }
}
