import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/widgets/question_breakdown_list.dart';
import '../../../quiz/presentation/widgets/score_ring.dart';
import '../../domain/entities/duel_final_result.dart';
import '../controllers/duel_controller.dart';
import '../models/duel_game_state.dart';

/// Post-duel summary — mirrors [ResultScreen], but for two players: an
/// outcome banner (won/lost/draw), the shared score ring, and a your-vs-
/// opponent correct-count comparison, alongside the same ball → XP row.
///
/// Reached once [DuelGameState.finalResult] arrives; clears the
/// controller's game state as soon as it builds (not from `dispose()` —
/// mutating provider state there is unsafe, see [DuelController]).
class DuelResultScreen extends ConsumerWidget {
  const DuelResultScreen({required this.game, super.key});

  final DuelGameState game;

  String _outcomeLabel(BuildContext context, DuelOutcome outcome) =>
      switch (outcome) {
        DuelOutcome.won => context.t.duelResult.won,
        DuelOutcome.lost => context.t.duelResult.lost,
        DuelOutcome.draw => context.t.duelResult.draw,
      };

  Color _outcomeColor(BuildContext context, DuelOutcome outcome) =>
      switch (outcome) {
        DuelOutcome.won => context.colors.green,
        DuelOutcome.lost => context.colors.error,
        DuelOutcome.draw => context.colors.muted,
      };

  // G'alaba/mag'lubiyat/durrang - bu ekranning eng katta lahzasi, lekin
  // hozirgacha buni hech narsa (haptic ma'nosida) his qildirmasdi -
  // savol darajasidagi to'g'ri/noto'g'ri haptic bilan bir xil mantiq
  // ([[duel_game_screen]]), faqat kattaroq, yakuniy lahza uchun.
  void _outcomeHaptic(DuelOutcome outcome) {
    switch (outcome) {
      case DuelOutcome.won:
        HapticFeedback.mediumImpact();
      case DuelOutcome.lost:
        HapticFeedback.heavyImpact();
      case DuelOutcome.draw:
        HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DuelFinalResult result = game.finalResult!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(duelControllerProvider.notifier).clearGame();
      _outcomeHaptic(result.outcome);
    });

    final double percent = result.yourScore.total == 0
        ? 0
        : result.yourScore.correct / result.yourScore.total;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xxl.vGap,
              FadeSlideIn(
                child: Center(
                  child: Text(
                    _outcomeLabel(context, result.outcome),
                    style: context.textStyles.titleLarge?.copyWith(
                      color: _outcomeColor(context, result.outcome),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Center(child: ScoreRing(percent: percent)),
              ),
              AppSpacing.md.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Center(
                  child: Text(
                    context.t.result.summary(
                      correct: result.yourScore.correct,
                      total: result.yourScore.total,
                    ),
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ScoreColumn(
                      label: context.t.duelResult.yourScoreLabel,
                      correct: result.yourScore.correct,
                      total: result.yourScore.total,
                    ),
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          '—',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ),
                    ),
                    _ScoreColumn(
                      label: context.t.duelResult.opponentScoreLabel,
                      correct: result.opponentScore.correct,
                      total: result.opponentScore.total,
                    ),
                  ],
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 220),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.target,
                            size: 16,
                            color: context.colors.ink,
                          ),
                          const SizedBox(width: 6),
                          AnimatedCounter(
                            value: result.ballEarned,
                            formatter: (v) =>
                                context.t.result.totalBall(ball: v),
                            style: context.textStyles.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: context.colors.ink,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        TablerIcons.arrowRight,
                        size: 14,
                        color: context.colors.muted,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            TablerIcons.bolt,
                            size: 16,
                            color: context.colors.coralDeep,
                          ),
                          const SizedBox(width: 6),
                          AnimatedCounter(
                            value: result.xpEarned,
                            formatter: (v) => context.t.result.xpEarned(xp: v),
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
              ),
              AppSpacing.xl.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 260),
                child: QuestionBreakdownList(items: result.breakdown),
              ),
              AppSpacing.xxl.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: AppButton.primary(
                  label: context.t.result.backToHome,
                  onPressed: () => context.go(AppRoutes.home),
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

class _ScoreColumn extends StatelessWidget {
  const _ScoreColumn({
    required this.label,
    required this.correct,
    required this.total,
  });

  final String label;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: context.textStyles.labelSmall),
        const SizedBox(height: 4),
        AnimatedCounter(
          value: correct,
          formatter: (v) => '$v/$total',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: context.colors.ink,
          ),
        ),
      ],
    );
  }
}
