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
import 'package:zukkor/features/friends/presentation/screens/friend_requests_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

final List<FriendRequest> _requests = [
  FriendRequest(
    id: 'req-1',
    fromUserId: '9',
    username: 'bekzod_xolmatov',
    firstName: 'Bekzod',
    lastName: 'Xolmatov',
    avatarColor: 'a-blue',
    avatarImagePath: null,
    createdAt: DateTime(2026, 7, 18),
  ),
  FriendRequest(
    id: 'req-2',
    fromUserId: '11',
    username: 'nodira_saidova',
    firstName: 'Nodira',
    lastName: 'Saidova',
    avatarColor: 'a-pink',
    avatarImagePath: null,
    createdAt: DateTime(2026, 7, 17),
  ),
];

/// Backendga murojaat qilmaydigan soxta friends repository — real
/// `GET /friends/requests/incoming` / accept / decline javobiga mos.
class _FakeFriendsRepository implements FriendsRepository {
  _FakeFriendsRepository({List<FriendRequest>? requests}) : _pending = List.of(requests ?? _requests);

  final List<FriendRequest> _pending;
  final List<String> acceptedIds = [];
  final List<String> declinedIds = [];

  @override
  Future<List<Friend>> getFriends() async => const [];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) => throw UnimplementedError();

  @override
  Future<void> sendFriendRequest(String userId) => throw UnimplementedError();

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => List.of(_pending);

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    acceptedIds.add(requestId);
    _pending.removeWhere((r) => r.id == requestId);
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    declinedIds.add(requestId);
    _pending.removeWhere((r) => r.id == requestId);
  }
}

/// Backendga murojaat qilmaydigan soxta leaderboard repository —
/// [PlayerDetailScreen] `GET /leaderboard/{user_id}`ni chaqiradi.
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
        rank: 9,
        username: 'bekzod_xolmatov',
        firstName: 'Bekzod',
        lastName: 'Xolmatov',
        avatarColor: 'a-blue',
        avatarImagePath: null,
        totalXp: 2800,
        currentStreak: 2,
        longestStreak: 6,
        gamesPlayed: 18,
        winRatePercent: 50,
      );
}

Future<({GoRouter router, _FakeFriendsRepository repository})> _pumpFriendRequests(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<FriendRequest>? requests,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeFriendsRepository repository = _FakeFriendsRepository(requests: requests);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.friendRequests,
    routes: [
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.friendRequests, builder: (context, state) => const FriendRequestsScreen()),
      GoRoute(
        path: AppRoutes.playerDetail,
        builder: (context, state) {
          final Map<dynamic, dynamic> extra = state.extra! as Map;
          return PlayerDetailScreen(
            args: PlayerDetailArgs(
              userId: extra['userId'] as String,
              relation: PlayerDetailRelation.values.firstWhere(
                (r) => r.name == extra['relation'],
                orElse: () => PlayerDetailRelation.unknown,
              ),
              incomingRequestId: extra['requestId'] as String?,
              initialRequestSent: extra['requestSent'] == true,
            ),
          );
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        friendsRepositoryProvider.overrideWithValue(repository),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, repository: repository);
}

void main() {
  testWidgets('renders title and both incoming requests, no overflow', (tester) async {
    await _pumpFriendRequests(tester);

    expect(find.text(AppStrings.friendRequestsTitle), findsOneWidget);
    expect(find.text('Bekzod Xolmatov'), findsOneWidget);
    expect(find.text('Nodira Saidova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpFriendRequests(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.friendRequestsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no incoming requests shows the empty state', (tester) async {
    await _pumpFriendRequests(tester, requests: const []);

    expect(find.text(AppStrings.friendRequestsEmptyState), findsOneWidget);
  });

  testWidgets('tapping accept calls the real accept request and removes the row', (tester) async {
    final result = await _pumpFriendRequests(tester);

    await tester.tap(find.byIcon(TablerIcons.check).first);
    await tester.pumpAndSettle();

    expect(result.repository.acceptedIds, ['req-1']);
    expect(find.text('Bekzod Xolmatov'), findsNothing);
    expect(find.text('Nodira Saidova'), findsOneWidget);
  });

  testWidgets('tapping decline calls the real decline request and removes the row', (tester) async {
    final result = await _pumpFriendRequests(tester);

    await tester.tap(find.byIcon(TablerIcons.x).first);
    await tester.pumpAndSettle();

    expect(result.repository.declinedIds, ['req-1']);
    expect(find.text('Bekzod Xolmatov'), findsNothing);
    expect(find.text('Nodira Saidova'), findsOneWidget);
  });

  testWidgets('tapping a request row opens their profile with Accept/Decline', (tester) async {
    final result = await _pumpFriendRequests(tester);

    await tester.tap(find.text('Bekzod Xolmatov'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerDetailScreen), findsOneWidget);
    expect(find.text(AppStrings.acceptRequestButton), findsOneWidget);
    expect(find.text(AppStrings.declineRequestButton), findsOneWidget);

    await tester.tap(find.text(AppStrings.acceptRequestButton));
    await tester.pumpAndSettle();

    expect(result.repository.acceptedIds, ['req-1']);
    expect(find.byType(PlayerDetailScreen), findsNothing);
    expect(find.text('Bekzod Xolmatov'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the back button returns to Friends when pushed on top of it', (tester) async {
    final result = await _pumpFriendRequests(tester);
    unawaited(result.router.push(AppRoutes.friends));
    await tester.pumpAndSettle();
    unawaited(result.router.push(AppRoutes.friendRequests));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(FriendRequestsScreen), findsNothing);
    expect(find.byType(FriendsScreen), findsOneWidget);
  });
}
