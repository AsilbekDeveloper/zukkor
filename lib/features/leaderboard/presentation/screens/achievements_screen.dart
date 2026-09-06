import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../domain/entities/player_stats.dart';
import '../controllers/my_stats_controller.dart';
import '../models/achievement.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerStats? stats = ref.watch(myStatsControllerProvider).data;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: 'Yutuqlaringiz', onBack: () => Navigator.of(context).pop()),
              AppSpacing.lg.vGap,
              Expanded(
                child: stats == null
                    ? const SizedBox.shrink()
                    : GridView.builder(
                        itemCount: allAchievements.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 140,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisExtent: 108,
                        ),
                        itemBuilder: (context, index) {
                          final Achievement achievement = allAchievements[index];
                          return AchievementBadge(
                            achievement: achievement,
                            unlocked: achievement.isUnlocked(stats),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
