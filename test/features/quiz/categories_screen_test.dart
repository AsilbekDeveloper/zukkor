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
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

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
        builder: (context, state) => CategoriesScreen(duelOpponent: state.extra as FriendEntry?),
      ),
      GoRoute(
        path: AppRoutes.quizIntro,
        builder: (context, state) => QuizIntroScreen(category: state.extra! as QuizCategory),
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
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
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

  testWidgets('tapping a category starts the quiz flow (Quiz Intro)', (tester) async {
    await _pumpCategories(tester);

    // A single pump (not pumpAndSettle): QuizIntroScreen runs its own
    // 700ms-tick countdown timer that keeps scheduling frames for ~4s
    // before auto-navigating onward — settling here would either time
    // out or hit the (unregistered, in this minimal test router) /quiz
    // route once the countdown finishes. `push` (not `go`) also leaves
    // Categories mounted underneath, so this checks the new screen
    // arrived rather than the old one being gone.
    await tester.tap(find.text('Math'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(QuizIntroScreen), findsOneWidget);
  });

  testWidgets('with a pending duel opponent, tapping a category opens Duel Waiting instead', (tester) async {
    const FriendEntry opponent = FriendEntry(
      name: 'Malika Yusupova',
      initials: 'MR',
      avatarColor: AvatarColorOption.teal,
      isOnline: true,
      statusLabel: 'Online',
    );
    await _pumpCategories(tester, duelOpponent: opponent);

    // Not pumpAndSettle: DuelWaitingScreen's waiting-dot animation repeats
    // forever, so settling here would time out.
    await tester.tap(find.text('History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DuelWaitingScreen), findsOneWidget);
    expect(find.byType(QuizIntroScreen), findsNothing);
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
