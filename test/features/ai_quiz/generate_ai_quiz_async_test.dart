import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/ai_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/generate_ai_quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/controllers/categories_controller.dart';
import 'package:zukkor/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:zukkor/features/wallet/domain/entities/currency_transaction.dart';
import 'package:zukkor/features/wallet/domain/entities/diamond_pricing.dart';
import 'package:zukkor/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeWalletRepository extends Fake implements WalletRepository {
  @override
  Future<DiamondPricing> getPricing() async => const DiamondPricing(
        inputUsdPer1mTokens: 1.5,
        outputUsdPer1mTokens: 7.5,
        diamondMarkupMultiplier: 4.0,
        usdPerDiamond: 0.001,
        charsPerTokenEstimate: 4,
      );

  @override
  Future<({List<CurrencyTransaction> entries, bool hasMore})> getTransactions({int limit = 30, int offset = 0}) async =>
      (entries: <CurrencyTransaction>[], hasMore: false);
}

class _FakeAiQuizRepository extends Fake implements AiQuizRepository {
  bool generateAsyncCalled = false;
  String jobStatus = 'completed';

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
    return (status: jobStatus, quiz: null, error: jobStatus == 'failed' ? 'AI xatosi' : null);
  }
}

class _FakeCategoriesController extends CategoriesController {
  @override
  Future<void> load() async {}
}

Future<GoRouter> _pumpGenerateScreen(WidgetTester tester, _FakeAiQuizRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: '/previous',
    routes: [
      GoRoute(path: '/previous', builder: (context, state) => const Scaffold(body: Text('Previous screen'))),
      GoRoute(path: '/generate', builder: (context, state) => const GenerateAiQuizScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        aiQuizRepositoryProvider.overrideWithValue(repo),
        categoriesControllerProvider.overrideWith(() => _FakeCategoriesController()),
        walletRepositoryProvider.overrideWithValue(_FakeWalletRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push('/generate'));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets(
    'GenerateAiQuizScreen calls generateAsync, shows a non-dismissible '
    '"generating" dialog, and pops back once the job completes',
    (tester) async {
      final repo = _FakeAiQuizRepository();
      await _pumpGenerateScreen(tester, repo);

      // Switch to Topic mode to avoid file picking
      await tester.tap(find.text('Topic'));
      await tester.pump();

      // Enter topic
      await tester.enterText(find.byType(TextField).first, 'Space');
      await tester.pump();

      // Tap generate - a "this will cost ~N Diamond" confirm dialog shows
      // first (2026-09-06, [[ai_cost_architecture]]); confirm it.
      await tester.tap(find.text('Generate'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(repo.generateAsyncCalled, isTrue);

      // The old "hujjatingiz qabul qilindi, bildirishnoma yuboramiz" (async
      // fire-and-forget) confirmation is gone - the user asked for the old
      // "tayyorlanmoqda" (in-progress) feel back (2026-09-06), so a
      // non-dismissible dialog shows immediately and stays up while the
      // (still-async, still-safe) background polling runs.
      expect(find.text(AppStrings.generatingTitle), findsOneWidget);

      // First poll tick (7s) sees 'completed' (the fake always returns
      // that) - the dialog closes itself and pops back to the previous
      // screen automatically, no button tap needed.
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.generatingTitle), findsNothing);
      expect(find.text('Previous screen'), findsOneWidget);
    },
  );

  testWidgets('a failed job closes the dialog and shows the error, without popping', (tester) async {
    final repo = _FakeAiQuizRepository()..jobStatus = 'failed';
    await _pumpGenerateScreen(tester, repo);

    await tester.tap(find.text('Topic'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Space');
    await tester.pump();
    await tester.tap(find.text('Generate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text(AppStrings.generatingTitle), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.generatingTitle), findsNothing);
    // Still on the Generate screen - a failure shouldn't navigate away.
    expect(find.text('Previous screen'), findsNothing);
  });
}
