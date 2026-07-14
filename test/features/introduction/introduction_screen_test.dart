import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/app.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/storage/app_preferences.dart';

/// A fresh install has no `hasSeenIntroduction` flag, so the app's own
/// router lands directly on the Introduction walkthrough — no manual
/// push needed, unlike the post-Introduction screens.
///
/// The explainer pages run continuous "breathing"/orbit animations for
/// as long as they're mounted, so `pumpAndSettle()` would never return —
/// every wait in this file uses a bounded [_settle] instead, long enough
/// for the one-shot page-transition/entrance animations to read out.
Future<SharedPreferences> _pumpAppOnIntroduction(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: const ZukkorApp(),
    ),
  );
  await _settle(tester);
  return prefs;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Confetti (900ms, one-shot) plus the async persist-and-navigate that
/// follows it — used only when finishing via "Get started".
Future<void> _settleAfterConfetti(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 950));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('page 1: welcome renders, no back button, Continue advances to page 2', (tester) async {
    await _pumpAppOnIntroduction(tester);

    expect(find.text(AppStrings.introWelcomeTitle), findsOneWidget);
    expect(find.byIcon(TablerIcons.arrowLeft), findsNothing);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await _settle(tester);

    expect(find.text(AppStrings.introSoloTitle), findsOneWidget);
    expect(find.byIcon(TablerIcons.arrowLeft), findsOneWidget);
  });

  testWidgets('page 1: language picker defaults to English and is selectable', (tester) async {
    await _pumpAppOnIntroduction(tester);

    expect(find.text(AppStrings.introLanguageLabel), findsOneWidget);
    expect(find.text(AppStrings.languageEnglish), findsOneWidget);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);
    expect(find.text(AppStrings.languageRussian), findsOneWidget);

    await tester.tap(find.text(AppStrings.languageUzbek));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('back button steps back through the explainer pages', (tester) async {
    await _pumpAppOnIntroduction(tester);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await _settle(tester);
    expect(find.text(AppStrings.introSoloTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await _settle(tester);

    expect(find.text(AppStrings.introWelcomeTitle), findsOneWidget);
  });

  testWidgets('interests page: selecting Other reveals a free-text field', (tester) async {
    await _pumpAppOnIntroduction(tester);

    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text(AppStrings.onboardingContinue));
      await _settle(tester);
    }

    expect(find.text(AppStrings.introInterestsTitle), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.text('Math'));
    await tester.pump();

    await tester.tap(find.text(AppStrings.introOtherOption));
    await tester.pump();

    expect(find.byType(TextFormField), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Chess');
    expect(find.text('Chess'), findsOneWidget);
  });

  testWidgets(
      'study page: choosing "Other" for study place reveals a text field, quiz-liking is selectable',
      (tester) async {
    await _pumpAppOnIntroduction(tester);

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.text(AppStrings.onboardingContinue));
      await _settle(tester);
    }

    expect(find.text(AppStrings.introStudyTitle), findsOneWidget);
    expect(find.text(AppStrings.introGetStarted), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);

    await tester.tap(find.text(AppStrings.introOtherOption));
    await tester.pump();
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.tap(find.text(AppStrings.introQuizLikingNotReally));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Skip jumps straight to Login and persists the flag', (tester) async {
    final SharedPreferences prefs = await _pumpAppOnIntroduction(tester);

    await tester.tap(find.text(AppStrings.introSkip));
    await _settle(tester);

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(prefs.getBool('zukkor.has_seen_introduction'), isTrue);
  });

  testWidgets('completing all 6 pages lands on Login and persists the flag', (tester) async {
    final SharedPreferences prefs = await _pumpAppOnIntroduction(tester);

    for (int i = 0; i < 5; i++) {
      await tester.tap(find.text(AppStrings.onboardingContinue));
      await _settle(tester);
    }

    expect(find.text(AppStrings.introStudyTitle), findsOneWidget);

    await tester.tap(find.text(AppStrings.introGetStarted));
    await _settleAfterConfetti(tester);

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(prefs.getBool('zukkor.has_seen_introduction'), isTrue);
  });
}
