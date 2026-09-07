import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../domain/entities/player_stats.dart';
import '../controllers/my_stats_controller.dart';
import '../models/achievement.dart';
import '../widgets/achievement_badge.dart';

/// Yutuqlar ro'yxati (badge grid) — [PlayerStats] asosida qaysi yutuqlar
/// ochilganini ko'rsatadi. `myStatsControllerProvider` odatda Home/Profile
/// tomonidan allaqachon yuklangan bo'ladi, lekin bu ekran ENDI o'zi ham
/// mustaqil yuklay oladi — avval `stats == null` bo'lsa ekran abadiy
/// bo'sh qolardi (na shimmer, na xato/qayta urinish).
///
/// HOZIRGI HOLAT: bu ekranga hech qanday tugma olib bormaydi — Home'dan
/// 2026-09-06'da olib tashlangan (keyingi versiyaga qoldirilgan qaror),
/// lekin marshrut va kod atayin saqlab qolingan.
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(myStatsControllerProvider).data == null) {
      Future.microtask(_loadStats);
    }
  }

  Future<void> _loadStats() async {
    String? userId = ref.read(currentUserControllerProvider).data?.id;
    if (userId == null) {
      await ref.read(currentUserControllerProvider.notifier).load();
      userId = ref.read(currentUserControllerProvider).data?.id;
    }
    if (userId != null) {
      await ref.read(myStatsControllerProvider.notifier).load(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myStatsState = ref.watch(myStatsControllerProvider);
    final PlayerStats? stats = myStatsState.data;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.achievements.title,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: myStatsState.hasError
                    ? ErrorRetryView(onRetry: _loadStats)
                    : stats == null
                    ? const ShimmerAchievementGridSkeleton()
                    : FadeSlideIn(
                        child: GridView.builder(
                          itemCount: allAchievements.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 140,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisExtent: 108,
                              ),
                          itemBuilder: (context, index) {
                            final Achievement achievement =
                                allAchievements[index];
                            return AchievementBadge(
                              achievement: achievement,
                              unlocked: achievement.isUnlocked(stats),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
