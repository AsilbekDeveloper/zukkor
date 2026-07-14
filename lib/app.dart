import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/responsive/responsive.dart';
import 'package:zukkor/core/router/app_router.dart';
import 'package:zukkor/core/theme/app_theme.dart';

import 'core/theme/theme_controller.dart';

class ZukkorApp extends ConsumerWidget {
  const ZukkorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeControllerProvider),
      routerConfig: ref.watch(appRouterProvider),
      // Sistema shrift masshtabi juda katta qo'yilganda ham UI buzilmasin.
      builder: (context, child) => clampTextScaling(context, child),
    );
  }
}