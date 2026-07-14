import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';

Future<GoRouter> _pumpLobby(
  WidgetTester tester, {
  required LobbyRole role,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => QuizScreen(category: state.extra! as QuizCategory),
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.lobby, extra: role));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('host: renders the room code, roster and Start button, no overflow', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host);

    expect(find.text(AppStrings.roomCodeLabel), findsOneWidget);
    expect(find.text('482913'), findsOneWidget);
    expect(find.text(AppStrings.playerCount(4, 20)), findsOneWidget);
    expect(find.text('Aziz'), findsOneWidget);
    expect(find.text('Malika'), findsOneWidget);
    expect(find.text('Shohruh'), findsOneWidget);
    expect(find.text('Dilnoza'), findsOneWidget);
    expect(find.byIcon(TablerIcons.crown), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest: adds "You" to the roster and shows the waiting indicator', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.guest);

    expect(find.text(AppStrings.playerCount(5, 20)), findsOneWidget);
    expect(find.text(AppStrings.currentUserName), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host, size: const Size(360, 780));

    expect(find.text(AppStrings.roomCodeLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('host: "Start the game" navigates to the Quiz screen', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host);

    await tester.tap(find.text(AppStrings.startGameButton));
    await tester.pumpAndSettle();

    expect(find.byType(QuizScreen), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpLobby(tester, role: LobbyRole.host);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.lobby, extra: LobbyRole.host));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.lobbyScreenTitle), findsNothing);
  });
}
