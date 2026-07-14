import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';

/// A short FAQ list, each question expandable to its answer.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<(String question, String answer)> _faqs = [
    (AppStrings.faqDuelQuestion, AppStrings.faqDuelAnswer),
    (AppStrings.faqXpQuestion, AppStrings.faqXpAnswer),
    (AppStrings.faqStreakQuestion, AppStrings.faqStreakAnswer),
    (AppStrings.faqLobbyQuestion, AppStrings.faqLobbyAnswer),
    (AppStrings.faqReportQuestion, AppStrings.faqReportAnswer),
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
              BackHeader(title: AppStrings.settingsHelpCenter, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              for (int i = 0; i < _faqs.length; i++) ...[
                _FaqTile(question: _faqs[i].$1, answer: _faqs[i].$2),
                if (i < _faqs.length - 1) AppSpacing.xs.vGap,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm + 2),
          iconColor: context.colors.coralDeep,
          collapsedIconColor: context.colors.muted,
          title: Text(
            question,
            style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.ink2, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
