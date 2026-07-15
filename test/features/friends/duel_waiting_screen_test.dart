import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/models/avatar_color_option.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/models/duel_match.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_waiting_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const FriendEntry _opponent = FriendEntry(
  name: 'Malika Yusupova',
  initials: 'MR',
  avatarColor: AvatarColorOption.teal,
  isOnline: true,
  statusLabel: 'Online',
);
final DuelMatch _match = DuelMatch(opponent: _opponent, category: QuizCategory.sample.first);

Future<GoRouter> _pumpDuelWaiting(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.duelWaiting,
        builder: (context, state) => DuelWaitingScreen(match: state.extra! as DuelMatch),
      ),
      GoRoute(
        path: AppRoutes.quizIntro,
        builder: (context, state) => QuizIntroScreen(category: state.extra! as QuizCategory),
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
  unawaited(router.push(AppRoutes.duelWaiting, extra: _match));
  // Not pumpAndSettle: LobbyWaitingIndicator's dot animation repeats
  // forever, so settling here would time out.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return router;
}

void main() {
  testWidgets('renders the opponent, category and waiting indicator, no overflow', (tester) async {
    await _pumpDuelWaiting(tester);

    expect(find.text(AppStrings.duelWaitingTitle), findsOneWidget);
    expect(find.text('Malika Yusupova'), findsOneWidget);
    // Home stays mounted underneath (pushed on top of it) and has its own
    // "Math" category tile, so at least one match is enough here.
    expect(find.text('Math'), findsWidgets);
    expect(find.text(AppStrings.waitingForAnswerLabel), findsOneWidget);
    expect(find.text(AppStrings.startDemoButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpDuelWaiting(tester, size: const Size(360, 780));

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping "Start (demo)" opens the Quiz Intro countdown', (tester) async {
    await _pumpDuelWaiting(tester);

    // A single bounded pump — QuizIntroScreen runs its own countdown
    // timer, so pumpAndSettle would time out (matches the established
    // pattern in categories_screen_test.dart).
    await tester.tap(find.text(AppStrings.startDemoButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(QuizIntroScreen), findsOneWidget);
  });

  testWidgets('the close button returns to Home when pushed on top of it', (tester) async {
    await _pumpDuelWaiting(tester);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(DuelWaitingScreen), findsNothing);
  });
}
