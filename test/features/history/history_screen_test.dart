import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';

Future<GoRouter> _pumpHistory(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryScreen()),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.history));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders title, all 6 rows and their results by default, no overflow', (tester) async {
    await _pumpHistory(tester);

    expect(find.text(AppStrings.gameHistory), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Football'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);

    expect(find.text('8/10'), findsOneWidget);
    expect(find.text('2nd place'), findsOneWidget);
    expect(find.text('6/10'), findsOneWidget);
    expect(find.text('10/10'), findsOneWidget);
    expect(find.text(AppStrings.historyWinBadge), findsOneWidget);
    expect(find.text(AppStrings.historyLossBadge), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpHistory(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.gameHistory), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Solo segment shows only solo games', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentSolo));
    await tester.pumpAndSettle();

    expect(find.text('Math'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(find.text('History'), findsNothing);
    expect(find.text('Movies'), findsNothing);
    expect(find.text('Football'), findsNothing);
  });

  testWidgets('the Duel segment shows only duel games', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentDuel));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text(AppStrings.historyWinBadge), findsOneWidget);
    expect(find.text(AppStrings.historyLossBadge), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('English'), findsNothing);
    expect(find.text('Memes'), findsNothing);
    expect(find.text('Football'), findsNothing);
  });

  testWidgets('the Lobby segment shows only lobby games', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentLobby));
    await tester.pumpAndSettle();

    expect(find.text('Football'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('History'), findsNothing);
    expect(find.text('English'), findsNothing);
    expect(find.text('Movies'), findsNothing);
    expect(find.text('Memes'), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);
  });
}
