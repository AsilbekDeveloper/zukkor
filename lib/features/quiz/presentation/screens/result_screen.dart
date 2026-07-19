import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../models/quiz_launch_args.dart';
import '../models/quiz_result.dart';
import '../widgets/score_ring.dart';

/// Post-quiz summary — mirrors the prototype's `view-result`: an
/// animated score ring, correct/total count, a ball → XP derivation row,
/// and 3 actions (play the same category again, challenge a friend, or
/// go home). Reached via [BallRevealScreen], which already plays the
/// celebratory reveal (sound + confetti).
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
                child: Text(context.t.result.label, style: context.textStyles.labelSmall),
              ),
              AppSpacing.lg.vGap,
              Center(child: ScoreRing(percent: result.percent)),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  context.t.result.summary(correct: result.correctCount, total: result.totalCount),
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(TablerIcons.target, size: 16, color: context.colors.ink),
                        const SizedBox(width: 6),
                        Text(
                          context.t.result.totalBall(ball: result.totalBall),
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.colors.ink,
                          ),
                        ),
                      ],
                    ),
                    Icon(TablerIcons.arrowRight, size: 14, color: context.colors.muted),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(TablerIcons.bolt, size: 16, color: context.colors.coralDeep),
                        const SizedBox(width: 6),
                        Text(
                          context.t.result.xpEarned(xp: result.xpEarned),
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.colors.coralDeep,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.xxl.vGap,
              AppButton.primary(
                label: context.t.result.playAgain,
                icon: const Icon(TablerIcons.refresh, color: Colors.white, size: 18),
                onPressed: () => context.pushReplacement(
                  AppRoutes.quiz,
                  extra: QuizLaunchArgs(category: result.category, questionCount: result.questionCount),
                ),
              ),
              AppSpacing.sm.vGap,
              AppButton.secondary(
                label: context.t.result.challengeAFriend,
                icon: Icon(TablerIcons.swords, color: context.colors.coralDeep, size: 18),
                onPressed: () => context.push(AppRoutes.duel),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(context.t.result.backToHome),
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
