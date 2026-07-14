import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/extensions/num_x.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/presentation/widgets/brand_logo.dart';

/// Sessiya tiklanayotganda ko'rinadigan qisqa ekran.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
