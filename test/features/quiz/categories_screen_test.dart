import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/models/avatar_color_option.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/models/duel_match.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_waiting_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_launch_args.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta quiz repository — Categories
/// ekrani ochilganda `GET /categories`ni chaqiradi, haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, name: 'Math', iconName: 'math-symbols', colorKey: 'coral', questionCount: 120),
        Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
        Category(id: 3, name: 'English', iconName: 'language', colorKey: 'teal', questionCount: 150),
        Category(id: 4, name: 'Movies', iconName: 'movie', colorKey: 'pink', questionCount: 76),
        Category(
          id: 5,
          name: 'Football',
          iconName: 'ball-football',
          colorKey: 'green',
          questionCount: 64,
        ),
        Category(id: 6, name: 'Memes', iconName: 'mood-smile', colorKey: 'blue', questionCount: 50),
      ];

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) =>
      throw UnimplementedError();

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> reportQuestion({required int questionId, required String reason, String? comment}) =>
      throw UnimplementedError();
}

Future<GoRouter> _pumpCategories(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  FriendEntry? duelOpponent,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.categories,
    initialExtra: duelOpponent,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) {
          final Object? extra = state.extra;
          if (extra is FriendEntry) {
            return CategoriesScreen(
              onCategoryPicked: (context, ref, category) => context.push(
                AppRoutes.quizSetup,
                extra: (
                  category: category,
                  onStart: (BuildContext ctx, WidgetRef ref, int count) => ctx.push(
                    AppRoutes.duelWaiting,
                    extra: DuelMatch(opponent: extra, category: category, questionCount: count),
                  ),
                ),
              ),
            );
          }
          return const CategoriesScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.quizSetup,
        builder: (context, state) {
          final extra = state.extra! as ({QuizCategory category, void Function(BuildContext, WidgetRef, int) onStart});
          return QuizSetupScreen(category: extra.category, onStart: extra.onStart);
        },
      ),
      GoRoute(
        path: AppRoutes.quizIntro,
        builder: (context, state) => QuizIntroScreen(args: state.extra! as QuizLaunchArgs),
      ),
      GoRoute(
        path: AppRoutes.duelWaiting,
        builder: (context, state) => DuelWaitingScreen(match: state.extra! as DuelMatch),
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
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all sample categories with no overflow', (tester) async {
    await _pumpCategories(tester);

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpCategories(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a category opens the question-count picker (Quiz Setup)', (tester) async {
    await _pumpCategories(tester);

    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();

    expect(find.byType(QuizSetupScreen), findsOneWidget);
  });

  testWidgets('with a pending duel opponent, tapping a category opens Quiz Setup, then Duel Waiting',
      (tester) async {
    const FriendEntry opponent = FriendEntry(
      name: 'Malika Yusupova',
      username: 'malika_yusupova',
      initials: 'MR',
      avatarColor: AvatarColorOption.teal,
    );
    await _pumpCategories(tester, duelOpponent: opponent);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // The question-count picker comes first for a duel too, same as solo.
    expect(find.byType(QuizSetupScreen), findsOneWidget);
    expect(find.byType(DuelWaitingScreen), findsNothing);

    await tester.tap(find.text(t.quizSetup.startButton));
    // Not pumpAndSettle from here: DuelWaitingScreen's waiting-dot
    // animation repeats forever, so settling would time out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DuelWaitingScreen), findsOneWidget);
    expect(find.text('Malika Yusupova'), findsOneWidget);
    // Categories stays mounted underneath (pushed on top of it) and has
    // its own "History" category tile, so at least one match is enough.
    expect(find.text('History'), findsWidgets);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpCategories(tester);
    // Simulate arriving here the normal way — pushed on top of Home —
    // so "back" has somewhere to go.
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.categories));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.categoriesScreenTitle), findsNothing);
  });
}
