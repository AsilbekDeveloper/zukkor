import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../models/quiz_launch_args.dart';
import '../models/quiz_result.dart';
import '../widgets/score_ring.dart';

/// Post-quiz summary — mirrors the prototype's `view-result`: an
/// animated score ring, correct/total count, XP earned, and 3 actions
/// (play the same category again, challenge a friend, or go home).
class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.result, super.key});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xxl.vGap,
              Center(
                child: Text(AppStrings.resultLabel, style: context.textStyles.labelSmall),
              ),
              AppSpacing.lg.vGap,
              Center(child: ScoreRing(percent: result.percent)),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  AppStrings.resultSummary(result.correctCount, result.totalCount),
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(TablerIcons.bolt, size: 16, color: context.colors.coralDeep),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.xpEarnedLabel(result.xpEarned),
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.colors.coralDeep,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.xxl.vGap,
              AppButton.primary(
                label: AppStrings.playAgain,
                icon: const Icon(TablerIcons.refresh, color: Colors.white, size: 18),
                onPressed: () => context.pushReplacement(
                  AppRoutes.quiz,
                  extra: QuizLaunchArgs(category: result.category),
                ),
              ),
              AppSpacing.sm.vGap,
              AppButton.secondary(
                label: AppStrings.challengeAFriendButton,
                icon: Icon(TablerIcons.swords, color: context.colors.coralDeep, size: 18),
                onPressed: () => context.push(AppRoutes.duel),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(AppStrings.backToHome),
                ),
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}
