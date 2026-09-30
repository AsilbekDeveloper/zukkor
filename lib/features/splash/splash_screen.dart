import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_x.dart';
import '../../core/extensions/num_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/app_preferences.dart';
import '../../core/storage/token_storage.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/presentation/controllers/current_user_controller.dart';
import '../auth/presentation/widgets/brand_logo.dart';
import '../history/presentation/controllers/weekly_activity_controller.dart';
import '../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../notifications/presentation/controllers/notifications_controller.dart';
import '../quiz/presentation/controllers/categories_controller.dart';

/// Ilovaning kirish nuqtasi. Saqlangan sessiyani tekshirib, tegishli
/// ekranga yo'naltiradi:
///
///  - refresh token bor  → Home (kirilgan; access token eskirsa interceptor
///    yangilaydi)
///  - token yo'q, Introduction ko'rilmagan → Introduction
///  - token yo'q, Introduction ko'rilgan   → Login
///
/// Token o'qishda xatolik bo'lsa (masalan platforma kanali yo'q holat)
/// "kirilmagan" deb hisoblanadi — bu eng xavfsiz standart (Login).
///
/// Token bor bo'lsa, Home'ga o'tishdan OLDIN asosiy ma'lumotni (profil,
/// kategoriyalar, bildirishnomalar, so'ng statistika — login/register'dagi
/// [reloadEssentialDataForNewAccount] bilan bir xil to'plam) shu yerda,
/// spinner hali ko'rinib turganda yuklab olamiz: aks holda Home bo'sh/0
/// holatda ochilib, keyin fonda yuklangan kategoriyalar va streak "sakrab"
/// paydo bo'lardi — xuddi pull-to-refresh'da avval bo'lgan yo'qolib-ketish
/// holati kabi (bu yerda ma'lumotni birinchi marta olib kelayotgani sabab).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    String? refreshToken;
    try {
      refreshToken = await ref.read(tokenStorageProvider).readRefreshToken();
    } catch (_) {
      refreshToken = null;
    }
    if (!mounted) return;

    if (refreshToken != null) {
      try {
        await Future.wait([
          ref.read(currentUserControllerProvider.notifier).load(),
          ref.read(categoriesControllerProvider.notifier).load(),
          ref.read(notificationsControllerProvider.notifier).load(),
          ref.read(weeklyActivityControllerProvider.notifier).load(),
        ]);
        final String? userId = ref.read(currentUserControllerProvider).data?.id;
        if (userId != null) {
          await ref.read(myStatsControllerProvider.notifier).load(userId);
        }
      } catch (_) {
        // Tarmoq xatosi — Home o'zining "needsInitialLoad" mantig'i bilan
        // qayta urinadi, shuning uchun bu yerda ilovani ushlab turmaymiz.
      }
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    final bool seenIntro = ref.read(appPreferencesProvider).hasSeenIntroduction;
    context.go(seenIntro ? AppRoutes.login : AppRoutes.introduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(),
            AppSpacing.xl.vGap,
            SizedBox.square(
              dimension: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: context.colors.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
