import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_x.dart';
import '../../core/extensions/num_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/app_preferences.dart';
import '../../core/storage/token_storage.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/presentation/widgets/brand_logo.dart';

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
