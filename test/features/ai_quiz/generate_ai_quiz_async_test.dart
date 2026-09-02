import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/ai_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/generate_ai_quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/controllers/categories_controller.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeAiQuizRepository extends Fake implements AiQuizRepository {
  bool generateAsyncCalled = false;

  @override
  Future<String> generateAsync({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) async {
    generateAsyncCalled = true;
    return 'job-123';
  }

  @override
  Future<({String status, AiQuiz? quiz, String? error})> getAsyncJobStatus(String jobId) async {
    return (status: 'completed', quiz: null, error: null);
  }
}

class _FakeCategoriesController extends CategoriesController {
  @override
  Future<void> load() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GenerateAiQuizScreen calls generateAsync and shows confirmation', (tester) async {
    final repo = _FakeAiQuizRepository();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          aiQuizRepositoryProvider.overrideWithValue(repo),
          categoriesControllerProvider.overrideWith(() => _FakeCategoriesController()),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const GenerateAiQuizScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Topic mode to avoid file picking
    await tester.tap(find.text('Topic'));
    await tester.pump();

    // Enter topic
    await tester.enterText(find.byType(TextField).first, 'Space');
    await tester.pump();

    // Tap generate
    await tester.tap(find.text('Generate'));
    await tester.pump();

    expect(repo.generateAsyncCalled, isTrue);
    
    // Check for confirmation text
    expect(find.textContaining('Hujjatingiz qabul qilindi'), findsOneWidget);

    // Let the timer run at least once to see 'completed' and cancel itself
    await tester.pump(const Duration(seconds: 8));
  });
}
