import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/manual_question_input.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/quiz_question.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/ai_quiz/presentation/models/edit_manual_quiz_args.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/edit_manual_quiz_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// End-to-end coverage for the manual-quiz question editor (#4) - this
/// screen previously had zero interactive widget tests despite being a
/// fairly complex stateful flow (independent per-card save/add/delete,
/// each its own backend call). Backend correctness was already covered
/// by 47 tests in test_ai_quiz.py; this exercises the Flutter side.
class _FakeAiQuizRepository extends Fake implements AiQuizRepository {
  _FakeAiQuizRepository(this.questions);

  List<QuizQuestion> questions;
  final List<(int, int, ManualQuestionInput)> updateCalls = [];
  final List<(int, ManualQuestionInput)> addCalls = [];
  final List<(int, int)> deleteCalls = [];

  @override
  Future<List<QuizQuestion>> listQuestions(int quizId) async => questions;

  @override
  Future<QuizQuestion> addQuestion(
    int quizId,
    ManualQuestionInput question,
  ) async {
    addCalls.add((quizId, question));
    return QuizQuestion(
      id: 99,
      questionText: question.questionText,
      options: question.options,
      correctOptionIndex: question.correctOptionIndex,
    );
  }

  @override
  Future<QuizQuestion> updateQuestion(
    int quizId,
    int questionId,
    ManualQuestionInput question,
  ) async {
    updateCalls.add((quizId, questionId, question));
    return QuizQuestion(
      id: questionId,
      questionText: question.questionText,
      options: question.options,
      correctOptionIndex: question.correctOptionIndex,
    );
  }

  @override
  Future<void> deleteQuestion(int quizId, int questionId) async {
    deleteCalls.add((quizId, questionId));
  }
}

List<QuizQuestion> _twoQuestions() => const [
  QuizQuestion(
    id: 1,
    questionText: 'Savol birinchi?',
    options: ['a', 'b', 'c', 'd'],
    correctOptionIndex: 0,
  ),
  QuizQuestion(
    id: 2,
    questionText: 'Savol ikkinchi?',
    options: ['e', 'f', 'g', 'h'],
    correctOptionIndex: 1,
  ),
];

Future<_FakeAiQuizRepository> _pumpEditScreen(
  WidgetTester tester, {
  List<QuizQuestion>? questions,
}) async {
  // Tall enough that 3 full question cards fit without needing to
  // scroll a target into view before tapping it.
  tester.view.physicalSize = const Size(390, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final _FakeAiQuizRepository repository = _FakeAiQuizRepository(
    questions ?? _twoQuestions(),
  );

  SharedPreferences.setMockInitialValues({});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: '/edit',
    routes: [
      GoRoute(
        path: '/edit',
        builder: (context, state) => const EditManualQuizScreen(
          args: EditManualQuizArgs(quizId: 7, quizName: 'Mening quizim'),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        aiQuizRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('loads and shows every existing question with a Save button', (
    tester,
  ) async {
    await _pumpEditScreen(tester);

    expect(find.text(AppStrings.manualQuestionLabel(1)), findsOneWidget);
    expect(find.text(AppStrings.manualQuestionLabel(2)), findsOneWidget);
    expect(find.text('Savol birinchi?'), findsOneWidget);
    expect(find.text('Savol ikkinchi?'), findsOneWidget);
    expect(find.text(AppStrings.manualSaveQuestion), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editing an existing question and saving calls updateQuestion', (
    tester,
  ) async {
    final repository = await _pumpEditScreen(tester);

    await tester.enterText(find.text('Savol birinchi?'), 'Yangilangan savol?');
    await tester.tap(find.text(AppStrings.manualSaveQuestion).first);
    await tester.pumpAndSettle();

    expect(repository.updateCalls, hasLength(1));
    final (quizId, questionId, input) = repository.updateCalls.single;
    expect(quizId, 7);
    expect(questionId, 1);
    expect(input.questionText, 'Yangilangan savol?');
    expect(find.text(AppStrings.questionSaved), findsOneWidget);
  });

  testWidgets('adding a new question calls addQuestion and flips to Save', (
    tester,
  ) async {
    final repository = await _pumpEditScreen(tester);

    // Bottom persistent "+ Add question" button - always the last match
    // before this tap (the only one, since both existing cards already
    // have an id and show "Save" instead).
    await tester.tap(find.text(AppStrings.manualAddQuestion));
    await tester.pumpAndSettle();

    // The 2 existing cards have 5 fields each (question + 4 options) -
    // the new 3rd card's fields start right after, at index 10.
    const int newCardFirstFieldIndex = 10;
    await tester.enterText(
      find.byType(TextField).at(newCardFirstFieldIndex),
      'Yangi savol matni?',
    );
    for (int i = 1; i <= 4; i++) {
      await tester.enterText(
        find.byType(TextField).at(newCardFirstFieldIndex + i),
        'variant$i',
      );
    }
    await tester.pumpAndSettle();

    // Now 2 widgets show "+ Add question": the new card's own footer
    // button (not yet saved) and the persistent bottom button - tap the
    // first (the card's own).
    expect(find.text(AppStrings.manualAddQuestion), findsNWidgets(2));
    await tester.tap(find.text(AppStrings.manualAddQuestion).first);
    await tester.pumpAndSettle();

    expect(repository.addCalls, hasLength(1));
    final (quizId, input) = repository.addCalls.single;
    expect(quizId, 7);
    expect(input.questionText, 'Yangi savol matni?');
    expect(input.options, ['variant1', 'variant2', 'variant3', 'variant4']);
    expect(find.text(AppStrings.questionAdded), findsOneWidget);
    // The just-added card now shows "Save" instead of "+ Add question".
    expect(find.text(AppStrings.manualSaveQuestion), findsNWidgets(3));
  });

  testWidgets(
    'saving with an empty field shows a validation message, not a network call',
    (tester) async {
      final repository = await _pumpEditScreen(tester);

      await tester.enterText(find.text('Savol birinchi?'), '');
      await tester.tap(find.text(AppStrings.manualSaveQuestion).first);
      await tester.pumpAndSettle();

      expect(repository.updateCalls, isEmpty);
      expect(find.text(AppStrings.manualFillAllFields), findsOneWidget);
    },
  );

  testWidgets(
    'deleting an existing question asks for confirmation then calls deleteQuestion',
    (tester) async {
      final repository = await _pumpEditScreen(tester);

      await tester.tap(find.byIcon(TablerIcons.trash).first);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.deleteQuestionConfirmTitle), findsOneWidget);
      expect(repository.deleteCalls, isEmpty);

      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, [(7, 1)]);
      expect(find.text('Savol birinchi?'), findsNothing);
      // The remaining question renumbers to "Question 1".
      expect(find.text(AppStrings.manualQuestionLabel(1)), findsOneWidget);
    },
  );

  testWidgets('cancelling the delete confirmation keeps the question', (
    tester,
  ) async {
    final repository = await _pumpEditScreen(tester);

    await tester.tap(find.byIcon(TablerIcons.trash).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(repository.deleteCalls, isEmpty);
    expect(find.text('Savol birinchi?'), findsOneWidget);
  });

  testWidgets(
    'deleting a not-yet-saved draft removes it locally with no confirmation and no API call',
    (tester) async {
      final repository = await _pumpEditScreen(tester);

      await tester.tap(find.text(AppStrings.manualAddQuestion));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.manualQuestionLabel(3)), findsOneWidget);

      await tester.tap(find.byIcon(TablerIcons.trash).last);
      await tester.pumpAndSettle();

      // No confirm dialog for a draft that was never persisted.
      expect(find.text(AppStrings.deleteQuestionConfirmTitle), findsNothing);
      expect(repository.deleteCalls, isEmpty);
      expect(find.text(AppStrings.manualQuestionLabel(3)), findsNothing);
    },
  );
}
