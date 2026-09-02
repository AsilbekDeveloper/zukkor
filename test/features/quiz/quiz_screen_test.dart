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
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_question_data.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_summary.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_result.dart';
import 'package:zukkor/features/quiz/presentation/screens/ball_reveal_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/features/quiz/presentation/widgets/answer_button.dart';
import 'package:zukkor/i18n/strings.g.dart';

const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 120,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);

/// Backendga murojaat qilmaydigan soxta quiz repository — real
/// `POST /quiz/start` / `POST /quiz/{session_id}/answer` javobiga mos,
/// 5 ta savoldan iborat sessiya. Har doim option 0'ni to'g'ri deb
/// belgilaydi — testlar qaysi variant bosilishidan qat'i nazar to'g'ri
/// javob doim oshkor qilinishini tekshiradi.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) async =>
      QuizStartResult(sessionId: 'session-1', question: _questionFor(1));

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) async {
    final bool isCorrect = selectedOption == 0;
    if (sessionQuestionId >= 5) {
      return AnswerResult(
        isCorrect: isCorrect,
        correctOptionIndex: 0,
        ballEarned: isCorrect ? 900 : 0,
        summary: const QuizSummary(
          totalBall: 4200,
          correctCount: 4,
          totalQuestions: 5,
          xpEarned: 60,
          newTotalXp: 2200,
          breakdown: [],
        ),
      );
    }
    return AnswerResult(
      isCorrect: isCorrect,
      correctOptionIndex: 0,
      ballEarned: isCorrect ? 900 : 0,
      nextQuestion: _questionFor(sessionQuestionId + 1),
    );
  }

  @override
  Future<void> reportQuestion({required int questionId, required String reason, String? comment}) =>
      throw UnimplementedError();

  QuizQuestionData _questionFor(int order) => QuizQuestionData(
        sessionQuestionId: order,
        questionText: 'Question $order',
        options: const ['A', 'B', 'C', 'D'],
        correctOptionIndex: 0,
        order: order,
        total: 5,
        timeLimitMs: 15000,
      );
}

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
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
      ],
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
    await tester.pump(const Duration(milliseconds: 300));

    // The tapped option is index 0 — always correct in the fake — so it's
    // shown as picked-correct (a check icon).
    expect(find.byIcon(TablerIcons.check), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('answering all 5 questions navigates to the Ball Reveal, then Result screen', (tester) async {
    await _pumpQuiz(tester);

    for (int question = 1; question <= 5; question++) {
      expect(find.text(AppStrings.questionProgress(question, 5)), findsOneWidget);

      await tester.tap(find.byType(AnswerButton).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      if (question < 5) {
        await tester.pump();
      }
    }

    // The 5th answer's feedback delay pushReplaces to the ball-count-up
    // reveal first, not straight to Result.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BallRevealScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Not pumpAndSettle: the count-up + confetti animations complete on
    // their own timers — advance past both to reach Result.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('running out of time auto-locks the question as wrong', (tester) async {
    await _pumpQuiz(tester);

    // No tap — let the 15s per-question timer run out.
    await tester.pump(const Duration(seconds: 15));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(TablerIcons.check), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the back button shows a confirm dialog, and leaving returns to Home', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    // The confirm dialog is up — the quiz screen (and Home) aren't
    // reachable yet until the user actually confirms leaving.
    expect(find.text(t.gameLeave.soloTitle), findsOneWidget);
    expect(find.text(AppStrings.duelHeroTitle), findsNothing);

    await tester.tap(find.text(t.gameLeave.leave));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('the back button dialog: staying keeps the quiz open', (tester) async {
    await _pumpQuiz(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.gameLeave.stay));
    await tester.pumpAndSettle();

    // Dismissed without leaving - still on the quiz, not Home.
    expect(find.byType(AnswerButton), findsWidgets);
    expect(find.text(AppStrings.duelHeroTitle), findsNothing);
  });
}
