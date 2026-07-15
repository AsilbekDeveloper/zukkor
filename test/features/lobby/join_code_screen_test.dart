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
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/lobby/presentation/widgets/code_input_row.dart';
import 'package:zukkor/i18n/strings.g.dart';

Future<GoRouter> _pumpJoinCode(WidgetTester tester, {Size size = const Size(390, 844)}) async {
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
      GoRoute(path: AppRoutes.joinCode, builder: (context, state) => const JoinCodeScreen()),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
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
  unawaited(router.push(AppRoutes.joinCode));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders the hint, 6 code boxes and Join button, no overflow', (tester) async {
    await _pumpJoinCode(tester);

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(CodeInputRow.digitCount));
    expect(find.text(AppStrings.joinButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpJoinCode(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing a digit auto-advances focus to the next box', (tester) async {
    await _pumpJoinCode(tester);

    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.pump();

    final TextField secondBox = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(secondBox.focusNode!.hasFocus, isTrue);
  });

  testWidgets('tapping "Join" navigates to the Lobby screen as a guest', (tester) async {
    await _pumpJoinCode(tester);

    // Not pumpAndSettle: the guest Lobby shows a perpetually-looping
    // pulsing-dots indicator, which never "settles".
    await tester.tap(find.text(AppStrings.joinButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpJoinCode(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.joinCode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.joinCodeHint), findsNothing);
  });
}
