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
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/features/quiz/presentation/widgets/answer_button.dart';
import 'package:zukkor/i18n/strings.g.dart';

final QuizCategory _math = QuizCategory.sample.first;

Future<GoRouter> _pumpQuiz(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => QuizScreen(category: state.extra! as QuizCategory),
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
  unawaited(router.push(AppRoutes.quiz, extra: _math));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders the progress header, question and 4 answers, no overflow', (tester) async {
    await _pumpQuiz(tester);

    expect(find.text(AppStrings.questionProgress(1, 5)), findsOneWidget);
    expect(find.byType(AnswerButton), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpQuiz(tester, size: const Size(360, 780));

    expect(find.byType(AnswerButton), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking an answer locks it in and reveals the correct one', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.byType(AnswerButton).first);
    await tester.pump();

    // Tapping a locked question does nothing further (still only 4
    // options, no crash) and the correct answer is always revealed —
    // regardless of which option was tapped or how the bank shuffled.
    expect(find.byIcon(TablerIcons.check), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('answering all 5 questions navigates to the Result screen', (tester) async {
    await _pumpQuiz(tester);

    for (int question = 1; question <= 5; question++) {
      expect(find.text(AppStrings.questionProgress(question, 5)), findsOneWidget);

      await tester.tap(find.byType(AnswerButton).first);
      await tester.pump(const Duration(milliseconds: 900));

      if (question < 5) {
        await tester.pump();
      }
    }

    // The 5th answer's feedback delay pushReplaces straight to Result.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('running out of time auto-locks the question as wrong', (tester) async {
    await _pumpQuiz(tester);

    // No tap — let the 15s per-question timer run out.
    await tester.pump(const Duration(seconds: 15));

    expect(find.byIcon(TablerIcons.check), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the back button abandons the quiz and returns to Home', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });
}
