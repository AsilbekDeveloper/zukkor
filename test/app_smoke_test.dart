import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/app.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';

/// Butun ilova ulanishining smoke testi: ProviderScope + tema + router
/// birgalikda ishga tushadi, ilova to'g'ridan-to'g'ri Login ekranida ochiladi
/// (auth qatlami hali qurilmagani uchun sessiya tiklash yo'q).
/// Bu test o'tsa — ilova real qurilmada ham "ochilmay qolish" darajasida
/// buzilmagani kafolatlanadi.
void main() {
  testWidgets('ilova Login ekranida ochiladi', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.loginButton), findsWidgets);
    expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
  });

  testWidgets('Login → Register sahifasiga o\'tish va orqaga qaytish', (tester) async {
    // Standart test oynasi (800x600) telefon ekranidan torroq — pastdagi
    // havola ko'rinmay qolib, tap() xato beradi. Haqiqiy telefon o'lchamiga
    // moslashtiramiz.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);

    // Login → Register (alohida sahifaga push qilinadi).
    await tester.tap(find.text(AppStrings.switchToRegister));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
    expect(find.text(AppStrings.registerButton), findsWidgets);
    expect(find.text(AppStrings.confirmPasswordLabel), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsNothing);

    // Parollar mos kelmasa xato ko'rsatiladi.
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.passwordHint),
      'parol12345',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.confirmPasswordHint),
      'boshqaParol',
    );
    await tester.tap(find.text(AppStrings.registerButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.passwordMismatch), findsOneWidget);

    // Register → Login (orqaga qaytish havolasi). Mismatch xatosi qo'shimcha
    // joy egallagani uchun havola scroll ko'rinishidan tashqarida bo'lishi
    // mumkin — avval uni ko'rinadigan qilamiz.
    await tester.ensureVisible(find.text(AppStrings.switchToLogin));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.switchToLogin));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.registerTitle), findsNothing);
  });

  testWidgets('Register with a valid form navigates to Onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Reach Register directly — robust to whichever screen the router
    // currently opens on.
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    unawaited(context.push(AppRoutes.register));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.emailHint),
      'aziz@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.passwordHint),
      'parol12345',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.confirmPasswordHint),
      'parol12345',
    );
    await tester.tap(find.text(AppStrings.registerButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text(AppStrings.registerTitle), findsNothing);
  });

  testWidgets('Login with a valid form navigates to Home', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    unawaited(context.push(AppRoutes.login));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.emailHint),
      'aziz@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.passwordHint),
      'parol12345',
    );
    await tester.tap(find.text(AppStrings.loginButton).first);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsNothing);
  });
}
