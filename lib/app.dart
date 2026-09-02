import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zukkor/core/responsive/responsive.dart';
import 'package:zukkor/core/router/app_router.dart';
import 'package:zukkor/core/theme/app_theme.dart';

import 'core/locale/locale_controller.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/user_session.dart';
import 'i18n/strings.g.dart';

class ZukkorApp extends ConsumerWidget {
  const ZukkorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocale locale = ref.watch(localeControllerProvider);

    // Sessiya majburan tugaganda foydalanuvchini Login'ga qaytaradigan
    // ishlov beruvchini butun ilova umri davomida jonli saqlaymiz.
    ref.watch(sessionExpiryHandlerProvider);

    // Push-bildirishnoma bosilganda navigatsiya qiladigan ishlov beruvchi.
    ref.watch(pushNotificationHandlerProvider);

    return TranslationProvider(
      child: MaterialApp.router(
        title: t.common.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeControllerProvider),
        locale: locale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: ref.watch(appRouterProvider),
        // Sistema shrift masshtabi juda katta qo'yilganda ham UI buzilmasin.
        builder: (context, child) => clampTextScaling(context, child),
      ),
    );
  }
}