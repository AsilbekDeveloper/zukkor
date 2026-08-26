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
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_question_data.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_launch_args.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 120,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);

/// Backendga murojaat qilmaydigan soxta quiz repository — countdown
/// tugagach `QuizScreen` haqiqiy `POST /quiz/start`ni chaqiradi, bu
/// test faqat o'sha ekranga yetib borishni tekshiradi.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) async =>
      const QuizStartResult(
        sessionId: 'session-1',
        question: QuizQuestionData(
          sessionQuestionId: 1,
          questionText: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctOptionIndex: 1,
          order: 1,
          total: 5,
          timeLimitMs: 15000,
        ),
      );

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      throw UnimplementedError();
}

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
        builder: (context, state) => QuizIntroScreen(args: state.extra! as QuizLaunchArgs),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final QuizLaunchArgs args = state.extra! as QuizLaunchArgs;
          return QuizScreen(
            category: args.category,
            questionCount: args.questionCount,
          );
        },
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.quizIntro, extra: const QuizLaunchArgs(category: _math)));
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
