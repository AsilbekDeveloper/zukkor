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
import 'package:zukkor/features/leaderboard/presentation/models/leaderboard_entry.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

Future<GoRouter> _pumpFullLeaderboard(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.fullLeaderboard,
        builder: (context, state) => const FullLeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDetail,
        builder: (context, state) => PlayerDetailScreen(entry: state.extra! as LeaderboardEntry),
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
  unawaited(router.push(AppRoutes.fullLeaderboard));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders the title and all 11 ranked rows, no overflow', (tester) async {
    await _pumpFullLeaderboard(tester);

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    for (final LeaderboardEntry entry in LeaderboardEntry.sampleFull) {
      expect(find.text(entry.name), findsOneWidget, reason: '${entry.name} should be listed');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpFullLeaderboard(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping someone opens their Player Detail', (tester) async {
    await _pumpFullLeaderboard(tester);

    await tester.tap(find.text('Kamola Tursunova'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.playerDetailTitle), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(8, 3410)), findsOneWidget);
  });

  testWidgets('tapping your own ("You") row does nothing', (tester) async {
    await _pumpFullLeaderboard(tester);

    await tester.tap(find.text(AppStrings.currentUserName));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PlayerDetailScreen), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpFullLeaderboard(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.fullLeaderboard));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.fullLeaderboardTitle), findsNothing);
  });
}
