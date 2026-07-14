import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_invite_screen.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';

Future<GoRouter> _pumpDuelInvite(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.notifications,
    routes: [
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.duelInvite, builder: (context, state) => const DuelInviteScreen()),
      GoRoute(
        path: AppRoutes.quizIntro,
        builder: (context, state) => QuizIntroScreen(category: state.extra! as QuizCategory),
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.duelInvite));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the opponent, category and both actions, no overflow', (tester) async {
    await _pumpDuelInvite(tester);

    expect(find.text(AppStrings.duelInviteTitle), findsOneWidget);
    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text(AppStrings.challengesYouLabel), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text(AppStrings.acceptButton), findsOneWidget);
    expect(find.text(AppStrings.declineButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpDuelInvite(tester, size: const Size(360, 780));

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping "Accept" opens the Quiz Intro countdown', (tester) async {
    await _pumpDuelInvite(tester);

    await tester.tap(find.text(AppStrings.acceptButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(QuizIntroScreen), findsOneWidget);
  });

  testWidgets('tapping "Decline" returns to Notifications', (tester) async {
    await _pumpDuelInvite(tester);

    await tester.tap(find.text(AppStrings.declineButton));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byType(DuelInviteScreen), findsNothing);
  });

  testWidgets('the close button returns to Notifications', (tester) async {
    await _pumpDuelInvite(tester);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byType(DuelInviteScreen), findsNothing);
  });
}
