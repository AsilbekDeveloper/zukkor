import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
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

  String _outcomeLabel(BuildContext context, DuelOutcome outcome) => switch (outcome) {
        DuelOutcome.won => context.t.duelResult.won,
        DuelOutcome.lost => context.t.duelResult.lost,
        DuelOutcome.draw => context.t.duelResult.draw,
      };

  Color _outcomeColor(BuildContext context, DuelOutcome outcome) => switch (outcome) {
        DuelOutcome.won => context.colors.green,
        DuelOutcome.lost => context.colors.error,
        DuelOutcome.draw => context.colors.muted,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DuelFinalResult result = game.finalResult!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(duelControllerProvider.notifier).clearGame();
    });

    final double percent =
        result.yourScore.total == 0 ? 0 : result.yourScore.correct / result.yourScore.total;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xxl.vGap,
              Center(
                child: Text(
                  _outcomeLabel(context, result.outcome),
                  style: context.textStyles.titleLarge?.copyWith(
                    color: _outcomeColor(context, result.outcome),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AppSpacing.lg.vGap,
              Center(child: ScoreRing(percent: percent)),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  context.t.result.summary(correct: result.yourScore.correct, total: result.yourScore.total),
                  style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              AppSpacing.lg.vGap,
              Row(
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
                      child: Text('—', style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted)),
                    ),
                  ),
                  _ScoreColumn(
                    label: context.t.duelResult.opponentScoreLabel,
                    correct: result.opponentScore.correct,
                    total: result.opponentScore.total,
                  ),
                ],
              ),
              AppSpacing.lg.vGap,
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
                          context.t.result.totalBall(ball: result.ballEarned),
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
                label: context.t.result.backToHome,
                onPressed: () => context.go(AppRoutes.home),
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
  const _ScoreColumn({required this.label, required this.correct, required this.total});

  final String label;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: context.textStyles.labelSmall),
        const SizedBox(height: 4),
        Text(
          '$correct/$total',
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
