import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_result.dart';
import 'package:zukkor/features/quiz/presentation/screens/ball_reveal_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 120,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);
const QuizResult _soloResult =
    QuizResult(category: _math, correctCount: 4, totalCount: 5, xpEarned: 60, totalBall: 4200, breakdown: []);

Future<void> _pumpBallReveal(
  WidgetTester tester, {
  QuizResult? result,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.ballReveal,
        builder: (context, state) => BallRevealScreen(result: state.extra! as QuizResult),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => ResultScreen(result: state.extra! as QuizResult),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.ballReveal, extra: result ?? _soloResult));
  // Not pumpAndSettle: the count-up animation is bounded, but the
  // confetti burst it triggers on completion repeats particles for its
  // own duration — bounded pumps only, matching quiz_intro_screen_test.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('renders the title and ball label, no overflow', (tester) async {
    await _pumpBallReveal(tester);

    expect(find.text(AppStrings.ballRevealTitle), findsOneWidget);
    expect(find.text(AppStrings.ballRevealBallLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpBallReveal(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.ballRevealTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('counts up to the total ball, reveals XP, then auto-navigates to Result', (tester) async {
    await _pumpBallReveal(tester);

    // Advance past the count-up animation (1400ms) — the final ball total
    // is showing and the XP chip has faded in, but the auto-navigate
    // confetti timer hasn't fired yet.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('4200'), findsOneWidget);
    expect(find.text(AppStrings.xpEarnedLabel(60)), findsOneWidget);
    expect(find.byType(ResultScreen), findsNothing);

    // Advance past the confetti burst (900ms) — its completion triggers
    // the hand-off to Result.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
