import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/ai_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/discover_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/export/presentation/screens/export_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeAiQuizRepository extends Fake implements AiQuizRepository {
  _FakeAiQuizRepository([this.quizzes = const []]);

  final List<AiQuiz> quizzes;

  @override
  Future<List<AiQuiz>> list() async => quizzes;

  @override
  Future<List<DiscoverQuiz>> discover({int? categoryId}) async => const [];
}

class _FakeQuizRepository extends Fake implements QuizRepository {
  _FakeQuizRepository({Completer<List<int>>? exportCompleter})
    : _exportCompleter = exportCompleter;

  final Completer<List<int>>? _exportCompleter;

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<QuizStartResult> startQuiz({
    required int categoryId,
    required int questionCount,
  }) => throw UnimplementedError();

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) => throw UnimplementedError();

  @override
  Future<void> reportQuestion({
    required int questionId,
    required String reason,
    String? comment,
  }) => throw UnimplementedError();

  @override
  Future<List<int>> exportQuizPdf(int categoryId) =>
      _exportCompleter?.future ?? Future.error(UnimplementedError());

  @override
  Future<List<int>> exportQuizDocx(int categoryId) => throw UnimplementedError();
}

Future<void> _pumpExportScreen(
  WidgetTester tester, {
  List<AiQuiz> quizzes = const [],
  QuizRepository? quizRepository,
}) async {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.export,
    routes: [
      GoRoute(
        path: AppRoutes.export,
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        aiQuizRepositoryProvider.overrideWithValue(
          _FakeAiQuizRepository(quizzes),
        ),
        quizRepositoryProvider.overrideWithValue(
          quizRepository ?? _FakeQuizRepository(),
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

AiQuiz _quiz(int id, String name) => AiQuiz(
  id: id,
  name: name,
  questionCount: 10,
  createdAt: DateTime(2026, 1, 1),
  source: 'ai_document',
  visibility: 'private',
  topicCategoryId: null,
  topicCategoryName: null,
);

void main() {
  testWidgets('shows the empty state when the user has no quizzes', (
    tester,
  ) async {
    await _pumpExportScreen(tester, quizzes: const []);

    expect(find.text(t.export.emptyQuizzes), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lists the user\'s own quizzes with the PDF format selected', (
    tester,
  ) async {
    await _pumpExportScreen(
      tester,
      quizzes: [_quiz(1, 'Tarix testi'), _quiz(2, 'Matematika testi')],
    );

    expect(find.text('Tarix testi'), findsOneWidget);
    expect(find.text('Matematika testi'), findsOneWidget);
    expect(find.text(t.export.formatPdf), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a quiz opens the generating-PDF loading dialog', (
    tester,
  ) async {
    // Never-completing future - keeps the dialog open deterministically
    // instead of racing the fake repository's (near-instant) rejection.
    final Completer<List<int>> exportCompleter = Completer<List<int>>();
    await _pumpExportScreen(
      tester,
      quizzes: [_quiz(1, 'Tarix testi')],
      quizRepository: _FakeQuizRepository(exportCompleter: exportCompleter),
    );

    await tester.tap(find.text('Tarix testi'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(t.export.generatingDialog(name: 'Tarix testi')), findsOneWidget);
  });
}
