import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';

final QuizCategory _math = QuizCategory.sample.first;

Future<void> _pumpIntro(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const DuelScreen()),
      GoRoute(
        path: AppRoutes.quizIntro,
        builder: (context, state) => QuizIntroScreen(category: state.extra! as QuizCategory),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => QuizScreen(category: state.extra! as QuizCategory),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: router,
    ),
  );
  unawaited(router.push(AppRoutes.quizIntro, extra: _math));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// `push` (not `go`) leaves Home mounted underneath, and Home's streak
// chip happens to also render a bare "5" — scope every countdown-digit
// lookup to QuizIntroScreen's own subtree to stay unambiguous regardless
// of what's stacked below it.
Finder _introText(String text) =>
    find.descendant(of: find.byType(QuizIntroScreen), matching: find.text(text));

void main() {
  testWidgets('renders the category and starts the countdown at 5, no overflow', (tester) async {
    await _pumpIntro(tester);

    expect(_introText(_math.name), findsOneWidget);
    expect(_introText('5'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpIntro(tester, size: const Size(360, 780));

    expect(_introText(_math.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('counts down and then auto-navigates to the Quiz screen', (tester) async {
    await _pumpIntro(tester);

    expect(_introText('5'), findsOneWidget);

    for (final String expected in ['4', '3', '2', '1']) {
      await tester.pump(const Duration(milliseconds: 700));
      expect(_introText(expected), findsOneWidget);
    }

    // The 5th tick shows "Start!" instead of "0".
    await tester.pump(const Duration(milliseconds: 700));
    expect(_introText(AppStrings.quizStartLabel), findsOneWidget);

    // Held briefly, then replaced by the real Quiz screen.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
