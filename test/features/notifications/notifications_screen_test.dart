import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_invite_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';

Future<GoRouter> _pumpNotifications(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.duelInvite, builder: (context, state) => const DuelInviteScreen()),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.notifications));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all 5 notifications, no overflow', (tester) async {
    await _pumpNotifications(tester);

    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AppStrings.notifDuelChallenge), findsOneWidget);
    expect(find.text(AppStrings.notifStreakReminder), findsOneWidget);
    expect(find.text(AppStrings.notifTop50), findsOneWidget);
    expect(find.text(AppStrings.notifFriendRequest), findsOneWidget);
    expect(find.text(AppStrings.notifWelcome), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpNotifications(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.notificationsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the duel-challenge row opens Duel Invite', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text(AppStrings.notifDuelChallenge));
    await tester.pumpAndSettle();

    expect(find.byType(DuelInviteScreen), findsOneWidget);
  });

  testWidgets('tapping any other row shows a coming-soon snackbar', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text(AppStrings.notifWelcome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppStrings.comingSoon), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(NotificationsScreen), findsNothing);
  });
}
