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
import 'package:zukkor/features/history/data/repositories/history_repository_impl.dart';
import 'package:zukkor/features/history/domain/entities/session_history_entry.dart';
import 'package:zukkor/features/history/domain/repositories/history_repository.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta history repository — real
/// `GET /history` javobiga mos, 3 ta solo va 1 ta duel seans.
class _FakeHistoryRepository implements HistoryRepository {
  @override
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0}) async =>
      (hasMore: false, entries: [
        SessionHistoryEntry(
          sessionId: '1',
          categoryId: 1,
          categoryName: 'Math',
          categoryIconName: 'math-symbols',
          categoryColorKey: 'coral',
          finishedAt: DateTime.now(),
          correctCount: 8,
          totalQuestions: 10,
          totalBall: 7200,
          totalXpEarned: 72,
          mode: HistorySessionMode.solo,
        ),
        SessionHistoryEntry(
          sessionId: '2',
          categoryId: 3,
          categoryName: 'English',
          categoryIconName: 'language',
          categoryColorKey: 'teal',
          finishedAt: DateTime.now().subtract(const Duration(days: 1)),
          correctCount: 6,
          totalQuestions: 10,
          totalBall: 5400,
          totalXpEarned: 54,
          mode: HistorySessionMode.solo,
        ),
        SessionHistoryEntry(
          sessionId: '3',
          categoryId: 6,
          categoryName: 'Memes',
          categoryIconName: 'mood-smile',
          categoryColorKey: 'blue',
          finishedAt: DateTime.now().subtract(const Duration(days: 3)),
          correctCount: 10,
          totalQuestions: 10,
          totalBall: 9500,
          totalXpEarned: 95,
          mode: HistorySessionMode.solo,
        ),
        SessionHistoryEntry(
          sessionId: '4',
          categoryId: 2,
          categoryName: 'History',
          categoryIconName: 'book',
          categoryColorKey: 'terra',
          finishedAt: DateTime.now().subtract(const Duration(days: 2)),
          correctCount: 4,
          totalQuestions: 5,
          totalBall: 4200,
          totalXpEarned: 60,
          mode: HistorySessionMode.duel,
          opponent: const DuelHistoryOpponent(
            name: 'Malika Yusupova',
            avatarColor: 'a-teal',
            avatarImagePath: null,
          ),
          duelOutcome: DuelHistoryOutcome.won,
        ),
        SessionHistoryEntry(
          sessionId: '5',
          categoryId: 4,
          categoryName: 'Movies',
          categoryIconName: 'movie',
          categoryColorKey: 'pink',
          finishedAt: DateTime.now().subtract(const Duration(days: 4)),
          correctCount: 7,
          totalQuestions: 10,
          totalBall: 6300,
          totalXpEarned: 63,
          mode: HistorySessionMode.lobby,
          lobbyResult: const LobbyHistoryResult(rank: 2, participantCount: 4),
        ),
      ]);
}

/// Same shape, but no sessions at all — for the genuinely-empty case.
class _FakeEmptyHistoryRepository implements HistoryRepository {
  @override
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0}) async =>
      const (entries: <SessionHistoryEntry>[], hasMore: false);
}

/// Has sessions, but none of them lobby — for "this segment has nothing"
/// (distinct from history being genuinely empty).
class _FakeHistoryRepositoryNoLobby implements HistoryRepository {
  @override
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0}) async =>
      (hasMore: false, entries: [
        SessionHistoryEntry(
          sessionId: '1',
          categoryId: 1,
          categoryName: 'Math',
          categoryIconName: 'math-symbols',
          categoryColorKey: 'coral',
          finishedAt: DateTime.now(),
          correctCount: 8,
          totalQuestions: 10,
          totalBall: 7200,
          totalXpEarned: 72,
          mode: HistorySessionMode.solo,
        ),
      ]);
}

Future<GoRouter> _pumpHistory(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  HistoryRepository? repository,
}) async {
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
      GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        historyRepositoryProvider.overrideWithValue(repository ?? _FakeHistoryRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.history));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders title, all real sessions (solo and duel) and their results by default, no overflow',
      (tester) async {
    await _pumpHistory(tester);

    expect(find.text(AppStrings.gameHistory), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    expect(find.text('8/10'), findsOneWidget);
    expect(find.text('6/10'), findsOneWidget);
    expect(find.text('10/10'), findsOneWidget);
    expect(find.text(AppStrings.historyWinBadge), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpHistory(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.gameHistory), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Solo segment shows only the real solo sessions', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentSolo));
    await tester.pumpAndSettle();

    expect(find.text('Math'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Memes'), findsOneWidget);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('the Duel segment shows the real duel session with a win badge', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentDuel));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text(AppStrings.historyWinBadge), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('English'), findsNothing);
    expect(find.text('Memes'), findsNothing);
  });

  testWidgets('the Lobby segment shows the real lobby session with its placement', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.text(AppStrings.historySegmentLobby));
    await tester.pumpAndSettle();

    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.textContaining(AppStrings.historyLobbyPlayerCount(4)), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('an empty mode segment shows the "nothing of this type" empty state', (tester) async {
    await _pumpHistory(tester, repository: _FakeHistoryRepositoryNoLobby());

    await tester.tap(find.text(AppStrings.historySegmentLobby));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.historyEmptyState), findsOneWidget);
    expect(find.text('Math'), findsNothing);
  });

  testWidgets('shows the "no games yet" empty state when history is genuinely empty', (tester) async {
    await _pumpHistory(tester, repository: _FakeEmptyHistoryRepository());

    expect(find.text(AppStrings.historyNoGamesYet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpHistory(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);
  });
}
