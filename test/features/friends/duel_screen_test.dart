import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';

Future<GoRouter> _pumpDuel(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.duel,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const DuelScreen()),
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
  testWidgets('renders title and only online friends with no overflow', (tester) async {
    await _pumpDuel(tester);

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.chooseYourFriend), findsOneWidget);

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
    expect(find.text('Dilnoza Rustamova'), findsOneWidget);

    // Offline friends aren't eligible to be challenged right now.
    expect(find.text('Bekzod Xolmatov'), findsNothing);
    expect(find.text('Nilufar Yoqubova'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpDuel(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a duel button opens Categories as the duel category picker', (tester) async {
    await _pumpDuel(tester);

    await tester.tap(find.byIcon(TablerIcons.swords).first);
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpDuel(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.duel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.duelScreenTitle), findsNothing);
  });
}
