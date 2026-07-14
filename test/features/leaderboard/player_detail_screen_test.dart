import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/models/avatar_color_option.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/models/leaderboard_entry.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/player_detail_screen.dart';

// name.length == 7, matching the prototype's `seed = name.length` demo
// formula: level = 8 + (7%10) = 15, winRate = 55 + (7%35) = 62%, streak = 1 + (7%15) = 8.
const LeaderboardEntry _entry = LeaderboardEntry(
  rank: 2,
  name: 'Malika1',
  initials: 'MR',
  xp: 4510,
  avatarColor: AvatarColorOption.teal,
);

Future<GoRouter> _pumpPlayerDetail(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.playerDetail,
        builder: (context, state) => PlayerDetailScreen(entry: state.extra! as LeaderboardEntry),
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.playerDetail, extra: _entry));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders name, rank, seeded stats and the Add to friends button, no overflow', (tester) async {
    await _pumpPlayerDetail(tester);

    expect(find.text(_entry.name), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(2, 4510)), findsOneWidget);
    expect(find.text('15'), findsOneWidget); // level
    expect(find.text('62%'), findsOneWidget); // win rate
    expect(find.text('8'), findsOneWidget); // streak
    expect(find.text(AppStrings.addToFriendsButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpPlayerDetail(tester, size: const Size(360, 780));

    expect(find.text(_entry.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping "Add to friends" turns it into a disabled "Sent" state', (tester) async {
    await _pumpPlayerDetail(tester);

    await tester.tap(find.text(AppStrings.addToFriendsButton));
    await tester.pump();

    expect(find.text(AppStrings.friendRequestSentLabel), findsOneWidget);
    expect(find.text(AppStrings.addToFriendsButton), findsNothing);

    // Tapping again (now disabled) is a no-op, not a crash.
    await tester.tap(find.text(AppStrings.friendRequestSentLabel), warnIfMissed: false);
    await tester.pump();
    expect(find.text(AppStrings.friendRequestSentLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpPlayerDetail(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.playerDetail, extra: _entry));
    await tester.pumpAndSettle();

    expect(find.text(_entry.name), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(PlayerDetailScreen), findsNothing);
  });
}
