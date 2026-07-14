import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';

Future<GoRouter> _pumpFriends(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.friends,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.leaderboard, builder: (context, state) => const LeaderboardScreen()),
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.addFriend, builder: (context, state) => const AddFriendScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => CategoriesScreen(duelOpponent: state.extra as FriendEntry?),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders header, search bar, online row and friend list with no overflow', (tester) async {
    await _pumpFriends(tester);

    // "Friends" also appears as the (disabled, active) bottom-nav tab label.
    expect(find.text(AppStrings.navFriends), findsWidgets);
    expect(find.text(AppStrings.searchFriendsPlaceholder), findsOneWidget);
    // Also appears as the "Online" status label on 3 friend-list rows.
    expect(find.text(AppStrings.onlineSectionTitle), findsWidgets);
    expect(find.text(AppStrings.allFriendsSectionTitle), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // Online row (short names).
    expect(find.text('Malika'), findsOneWidget);
    expect(find.text('Shohruh'), findsOneWidget);
    expect(find.text('Dilnoza'), findsOneWidget);

    // All-friends list (full names).
    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
    expect(find.text('Dilnoza Rustamova'), findsOneWidget);
    expect(find.text('Bekzod Xolmatov'), findsOneWidget);
    expect(find.text('Nilufar Yoqubova'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpFriends(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.searchFriendsPlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the add-friend button navigates to the Add Friend screen', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.userPlus));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
  });

  testWidgets('typing in the search bar filters the list and hides Online', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'mal');
    await tester.pump();

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsNothing);
    // "Shohruh" (the short name) only appears in the Online avatar row —
    // its absence proves that row is hidden while searching.
    expect(find.text('Shohruh'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a search with no matches shows the empty state', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'zzz-no-such-friend');
    await tester.pump();

    expect(find.text(AppStrings.noFriendsFound), findsOneWidget);
    expect(find.text('Malika Yusupova'), findsNothing);
  });

  testWidgets('clearing the search restores the full list and Online row', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'mal');
    await tester.pump();
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pump();

    expect(find.text(AppStrings.onlineSectionTitle), findsWidgets);
    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
  });

  testWidgets('tapping an online friend avatar starts a duel with them', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.text('Malika'));
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
  });

  testWidgets('tapping a duel button on the All-friends list starts a duel with that friend', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.swords).first);
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
  });

  testWidgets('the duel button works for an offline friend too', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.swords).last);
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('the bottom nav Home tab navigates back to Home', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.home));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('the bottom nav Leaderboard tab navigates to Leaderboard', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.trophy));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
  });
}
