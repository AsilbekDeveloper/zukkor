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
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// "See all" and the center Play tab use go_router, so a real (if
/// minimal) router is still required — and the shared bottom-nav/button
/// widgets play a tap sound via Riverpod, so a `ProviderScope` is too.
Future<void> _pumpHome(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const DuelScreen()),
      GoRoute(path: AppRoutes.joinCode, builder: (context, state) => const JoinCodeScreen()),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders every section with no layout overflow', (tester) async {
    await _pumpHome(tester);

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.startDuel), findsOneWidget);
    expect(find.text(AppStrings.totalXpLabel), findsOneWidget);
    expect(find.text(AppStrings.rankLabel), findsOneWidget);
    expect(find.text(AppStrings.levelLabel), findsOneWidget);
    expect(find.text(AppStrings.createRoom), findsOneWidget);
    expect(find.text(AppStrings.joinWithCode), findsOneWidget);
    expect(find.text(AppStrings.categoriesTitle), findsOneWidget);
    expect(find.text(AppStrings.friendsOnline(3)), findsOneWidget);

    // One card per sample category.
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);

    // No RenderFlex overflow (or any other) errors were thrown mid-layout.
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders correctly on a wide (tablet) viewport, no overflow', (tester) async {
    // Standard mobile layout everywhere — on a wide viewport the single
    // column just stretches full-width, no special tablet treatment.
    await _pumpHome(tester, size: const Size(1024, 1366));

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.categoriesTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom nav bar fits on the smallest supported phone width', (tester) async {
    // 360 is the narrowest width the design explicitly targets — this is
    // exactly the case that overflowed before the Expanded-based fix.
    await _pumpHome(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(find.text(AppStrings.navLeaderboard), findsOneWidget);
    expect(find.text(AppStrings.navFriends), findsOneWidget);
    expect(find.text(AppStrings.navProfile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the notification bell opens Notifications', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byIcon(TablerIcons.bell));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('"Create a room" navigates to the Lobby screen as host', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.createRoom));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsOneWidget);
  });

  testWidgets('"Join with a code" navigates to the Join Code screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.joinWithCode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
  });

  testWidgets('tapping the active Home tab does nothing (no snackbar)', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.navHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppStrings.comingSoon), findsNothing);
  });

  testWidgets('the Start Duel pill keeps its natural width instead of stretching', (tester) async {
    await _pumpHome(tester);

    // Regression test: the button used to sit inside an Expanded, which
    // stretched it into a wide bar with the icon/label squashed to the
    // left instead of the intended compact pill shape.
    final double cardWidth = tester.getSize(
      find.text(AppStrings.duelHeroTitle),
    ).width;
    final double buttonWidth = tester.getSize(
      find.ancestor(
        of: find.text(AppStrings.startDuel),
        matching: find.byType(Material),
      ).first,
    ).width;

    expect(
      buttonWidth,
      lessThan(cardWidth),
      reason: 'Start Duel button should be a compact pill, not stretch to the card width',
    );

    // Tapping should still work correctly (both button and card render,
    // no interaction was accidentally broken by fixing the layout) and
    // now pushes the real Duel (choose a friend) screen.
    await tester.tap(find.text(AppStrings.startDuel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
  });

  testWidgets('the friends-online shortcut navigates to the Duel screen', (tester) async {
    // Tall viewport so the last list item isn't near the bottom nav bar's
    // raised center Play button, whose hit area extends above its own
    // bounding box and can otherwise steal the tap.
    await _pumpHome(tester, size: const Size(390, 1400));

    await tester.tap(find.text(AppStrings.friendsOnline(3)));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
  });

  testWidgets('"See all" navigates to the Categories screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.seeAll));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.duelHeroTitle), findsNothing);
  });

  testWidgets('the center Play tab navigates to the Categories screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byIcon(TablerIcons.playerPlay));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
  });
}
