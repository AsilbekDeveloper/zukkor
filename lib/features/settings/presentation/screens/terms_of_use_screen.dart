import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../widgets/policy_content.dart';

/// Static Terms of Use copy.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  List<PolicySection> _sections(BuildContext context) => [
        PolicySection(title: context.t.termsOfUse.accountTitle, body: context.t.termsOfUse.accountBody),
        PolicySection(title: context.t.termsOfUse.conductTitle, body: context.t.termsOfUse.conductBody),
        PolicySection(title: context.t.termsOfUse.contentTitle, body: context.t.termsOfUse.contentBody),
        PolicySection(title: context.t.termsOfUse.changesTitle, body: context.t.termsOfUse.changesBody),
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
              BackHeader(title: context.t.termsOfUse.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              PolicyContent(sections: _sections(context)),
            ],
          ),
        ),
      ),
    );
  }
}
