import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/app.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';

/// The onboarding wizard has no entry point wired up yet (login/register
/// submit are still TODO stubs), so tests reach it the same way a future
/// "registration succeeded" redirect will: by pushing the route directly.
Future<void> _pumpAppOnOnboarding(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Skips the Introduction walkthrough (its explainer pages run a
  // continuous animation that would make the pumpAndSettle below hang) —
  // this file only cares about the Onboarding wizard itself.
  SharedPreferences.setMockInitialValues(<String, Object>{'zukkor.has_seen_introduction': true});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: const ZukkorApp(),
    ),
  );
  await tester.pumpAndSettle();

  final BuildContext context = tester.element(find.byType(Scaffold).first);
  unawaited(context.push(AppRoutes.onboarding));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('step 1: avatar step renders and Continue advances to step 2', (tester) async {
    await _pumpAppOnOnboarding(tester);

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('step 2: empty form blocks advancing and shows errors', (tester) async {
    await _pumpAppOnOnboarding(tester);
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Still on step 2 — nothing progressed.
    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);
    expect(find.text(AppStrings.nameRequired), findsNWidgets(2));
    expect(find.text(AppStrings.usernameRequired), findsOneWidget);
  });

  testWidgets('step 3: no direction selected blocks Start and shows a hint', (tester) async {
    await _pumpAppOnOnboarding(tester);

    // Step 1 → 2.
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Fill step 2 and advance to 3.
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.firstNameHint),
      'Aziz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.lastNameHint),
      'Karimov',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.usernameHint),
      'aziz_karimov',
    );
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
    expect(find.text(AppStrings.onboardingStart), findsWidgets);

    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();

    // Still on step 3 — direction is required.
    expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
    expect(find.text(AppStrings.directionRequired), findsOneWidget);
  });

  testWidgets('happy path: all 3 steps completed lands on Home', (tester) async {
    await _pumpAppOnOnboarding(tester);

    // Step 1 → 2.
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 2 → 3.
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.firstNameHint),
      'Aziz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.lastNameHint),
      'Karimov',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.usernameHint),
      'aziz_karimov',
    );
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 3: pick a direction, then Start.
    await tester.tap(find.text(AppStrings.directionStudentUniTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('back button steps back through the wizard', (tester) async {
    await _pumpAppOnOnboarding(tester);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });
}
