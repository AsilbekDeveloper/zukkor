import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_launch_args.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_result.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

final QuizCategory _math = QuizCategory.sample.first;
final QuizResult _result = QuizResult(category: _math, correctCount: 4, totalCount: 5, xpEarned: 60);

Future<GoRouter> _pumpResult(WidgetTester tester, {Size size = const Size(390, 844)}) async {
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
        path: AppRoutes.quiz,
        builder: (context, state) {
          final QuizLaunchArgs args = state.extra! as QuizLaunchArgs;
          return QuizScreen(category: args.category, isLobbyGame: args.isLobbyGame);
        },
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
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.result, extra: _result));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders the score, summary and XP, no overflow', (tester) async {
    await _pumpResult(tester);

    expect(find.text(AppStrings.resultLabel), findsOneWidget);
    expect(find.text(AppStrings.resultSummary(4, 5)), findsOneWidget);
    expect(find.text(AppStrings.xpEarnedLabel(60)), findsOneWidget);
    expect(find.text(AppStrings.playAgain), findsOneWidget);
    expect(find.text(AppStrings.challengeAFriendButton), findsOneWidget);
    expect(find.text(AppStrings.backToHome), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the score ring animates up to 80%', (tester) async {
    await _pumpResult(tester);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('80%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpResult(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.resultLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Play again" starts a fresh Quiz for the same category', (tester) async {
    await _pumpResult(tester);

    await tester.tap(find.text(AppStrings.playAgain));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(QuizScreen), findsOneWidget);
  });

  testWidgets('"Challenge a friend" navigates to the Duel screen', (tester) async {
    await _pumpResult(tester);

    await tester.tap(find.text(AppStrings.challengeAFriendButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
  });

  testWidgets('"Back to home" navigates to Home', (tester) async {
    await _pumpResult(tester);

    await tester.tap(find.text(AppStrings.backToHome));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });
}
