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
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta leaderboard repository —
/// `GET /leaderboard/{user_id}`ga mos to'liq statistika qaytaradi.
class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) =>
      throw UnimplementedError();

  @override
  Future<PlayerStats> getPlayerStats(String userId) async => PlayerStats(
        userId: userId,
        rank: 2,
        username: 'malika',
        firstName: 'Malika',
        lastName: 'Yusupova',
        avatarColor: 'a-teal',
        avatarImagePath: null,
        totalXp: 4510,
        currentStreak: 8,
        longestStreak: 20,
        gamesPlayed: 40,
        winRatePercent: 62,
      );
}

/// Backendga murojaat qilmaydigan soxta friends repository — "Add to
/// friends" endi real `POST /friends/requests` chaqiradi.
class _FakeFriendsRepository implements FriendsRepository {
  final List<String> sentRequestUserIds = [];

  @override
  Future<List<Friend>> getFriends() async => const [];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) => throw UnimplementedError();

  @override
  Future<void> sendFriendRequest(String userId) async => sentRequestUserIds.add(userId);

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) => throw UnimplementedError();

  @override
  Future<void> declineFriendRequest(String requestId) => throw UnimplementedError();
}

Future<({GoRouter router, _FakeFriendsRepository friendsRepository})> _pumpPlayerDetail(
  WidgetTester tester, {
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
        path: AppRoutes.playerDetail,
        builder: (context, state) => const PlayerDetailScreen(args: PlayerDetailArgs(userId: '2')),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeFriendsRepository friendsRepository = _FakeFriendsRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        friendsRepositoryProvider.overrideWithValue(friendsRepository),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.playerDetail, extra: {'userId': '2'}));
  await tester.pumpAndSettle();
  return (router: router, friendsRepository: friendsRepository);
}

void main() {
  testWidgets('renders name, rank, real stats and the Add to friends button, no overflow', (tester) async {
    await _pumpPlayerDetail(tester);

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(2, 4510)), findsOneWidget);
    expect(find.text('62%'), findsOneWidget); // win rate
    expect(find.text('8'), findsOneWidget); // streak
    expect(find.text(AppStrings.addToFriendsButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpPlayerDetail(tester, size: const Size(360, 780));

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping "Add to friends" sends a real request and shows a disabled "Sent" state', (tester) async {
    final result = await _pumpPlayerDetail(tester);

    await tester.tap(find.text(AppStrings.addToFriendsButton));
    await tester.pump();
    await tester.pump();

    expect(result.friendsRepository.sentRequestUserIds, ['2']);
    expect(find.text(AppStrings.friendRequestSentLabel), findsOneWidget);
    expect(find.text(AppStrings.addToFriendsButton), findsNothing);

    // Tapping again (now disabled) is a no-op, not a crash.
    await tester.tap(find.text(AppStrings.friendRequestSentLabel), warnIfMissed: false);
    await tester.pump();
    expect(find.text(AppStrings.friendRequestSentLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the close button returns to Home when pushed on top of it', (tester) async {
    final result = await _pumpPlayerDetail(tester);
    final GoRouter router = result.router;
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.playerDetail, extra: {'userId': '2'}));
    await tester.pumpAndSettle();

    expect(find.text('Malika Yusupova'), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(PlayerDetailScreen), findsNothing);
  });
}
