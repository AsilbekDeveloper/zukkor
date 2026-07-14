import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/rank_filter_screen.dart';

/// Returns the router plus the `Future` the screen's own `push` resolves
/// with — the direct, unambiguous way to assert what a screen popped
/// with (rather than relying on a caller elsewhere reacting to it).
Future<(GoRouter, Future<String?>)> _pumpRankFilter(
  WidgetTester tester, {
  String? currentFilter,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.leaderboard,
    routes: [
      GoRoute(path: AppRoutes.leaderboard, builder: (context, state) => const LeaderboardScreen()),
      GoRoute(
        path: AppRoutes.rankFilter,
        builder: (context, state) => RankFilterScreen(currentFilter: state.extra as String?),
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  final Future<String?> resultFuture = router.push<String?>(AppRoutes.rankFilter, extra: currentFilter);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return (router, resultFuture);
}

void main() {
  testWidgets('renders "All categories" + all 6 categories, no overflow', (tester) async {
    await _pumpRankFilter(tester, currentFilter: null);

    expect(find.text(AppStrings.allCategories), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpRankFilter(tester, currentFilter: null, size: const Size(360, 780));

    expect(find.text(AppStrings.allCategories), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a category pops with that category name', (tester) async {
    final (_, Future<String?> resultFuture) = await _pumpRankFilter(tester, currentFilter: null);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(await resultFuture, 'History');
  });

  testWidgets('tapping "All categories" pops with null', (tester) async {
    final (_, Future<String?> resultFuture) = await _pumpRankFilter(tester, currentFilter: 'Math');

    await tester.tap(find.text(AppStrings.allCategories));
    await tester.pumpAndSettle();

    expect(await resultFuture, isNull);
  });

  testWidgets('the back button pops with the previously active filter unchanged', (tester) async {
    final (_, Future<String?> resultFuture) = await _pumpRankFilter(tester, currentFilter: 'English');

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(await resultFuture, 'English');
  });
}
