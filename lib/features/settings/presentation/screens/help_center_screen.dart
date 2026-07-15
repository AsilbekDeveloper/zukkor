import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';

/// A short FAQ list, each question expandable to its answer.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  List<(String question, String answer)> _faqs(BuildContext context) => [
        (context.t.helpCenter.duelQuestion, context.t.helpCenter.duelAnswer),
        (context.t.helpCenter.xpQuestion, context.t.helpCenter.xpAnswer),
        (context.t.helpCenter.streakQuestion, context.t.helpCenter.streakAnswer),
        (context.t.helpCenter.lobbyQuestion, context.t.helpCenter.lobbyAnswer),
        (context.t.helpCenter.reportQuestion, context.t.helpCenter.reportAnswer),
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
    final List<(String question, String answer)> faqs = _faqs(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.settings.helpCenter, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              for (int i = 0; i < faqs.length; i++) ...[
                _FaqTile(question: faqs[i].$1, answer: faqs[i].$2),
                if (i < faqs.length - 1) AppSpacing.xs.vGap,
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
