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
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const List<DiscoveredUser> _directory = [
  DiscoveredUser(
    id: '10',
    username: 'sardor_aliyev',
    firstName: 'Sardor',
    lastName: 'Aliyev',
    avatarColor: 'a-blue',
    avatarImagePath: null,
    requestPending: false,
  ),
];

/// Backendga murojaat qilmaydigan soxta friends repository — real
/// `GET /friends/search` / `POST /friends/requests` javobiga mos.
class _FakeFriendsRepository implements FriendsRepository {
  final List<String> addedUserIds = [];

  // FriendsScreen (reached via the back button) also reads this — must
  // resolve, not throw, or its spinner would never settle.
  @override
  Future<List<Friend>> getFriends() async => const [];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) async {
    final String needle = query.toLowerCase();
    return _directory
        .where((u) =>
            (u.username?.toLowerCase().contains(needle) ?? false) ||
            '${u.firstName} ${u.lastName}'.toLowerCase().contains(needle))
        .toList();
  }

  @override
  Future<void> sendFriendRequest(String userId) async => addedUserIds.add(userId);

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) async {}

  @override
  Future<void> declineFriendRequest(String requestId) async {}
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
        rank: 20,
        username: 'sardor_aliyev',
        firstName: 'Sardor',
        lastName: 'Aliyev',
        avatarColor: 'a-blue',
        avatarImagePath: null,
        totalXp: 1200,
        currentStreak: 1,
        longestStreak: 2,
        gamesPlayed: 5,
        winRatePercent: 40,
      );
}

Future<GoRouter> _pumpAddFriend(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  FriendsRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.addFriend,
    routes: [
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.addFriend, builder: (context, state) => const AddFriendScreen()),
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
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        friendsRepositoryProvider.overrideWithValue(repository ?? _FakeFriendsRepository()),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Types [query], then advances past the screen's 350ms debounce and lets
/// the (fake, near-instant) search request resolve.
Future<void> _search(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  testWidgets('renders title, search bar and invite code with no overflow', (tester) async {
    await _pumpAddFriend(tester);

    expect(find.text(AppStrings.addFriend), findsOneWidget);
    expect(find.text(AppStrings.searchByUsername), findsOneWidget);
    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
    expect(find.text(AppStrings.yourInviteCode), findsOneWidget);
    expect(find.text('ZKR-AZ312'), findsOneWidget);
    expect(find.text(AppStrings.shareLink), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpAddFriend(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.addFriend), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing in the search bar shows matching users and hides the invite section', (tester) async {
    await _pumpAddFriend(tester);

    await _search(tester, 'sardor');

    expect(find.text('Sardor Aliyev'), findsOneWidget);
    expect(find.text('@sardor_aliyev'), findsOneWidget);
    expect(find.text(AppStrings.orViaInviteLink), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a search with no matches shows the empty state', (tester) async {
    await _pumpAddFriend(tester);

    await _search(tester, 'zzz-no-such-user');

    expect(find.text(AppStrings.noUsersFound), findsOneWidget);
  });

  testWidgets('tapping Add on a result calls the real add-friend request and shows Added', (tester) async {
    final _FakeFriendsRepository repository = _FakeFriendsRepository();
    await _pumpAddFriend(tester, repository: repository);

    await _search(tester, 'sardor');

    await tester.tap(find.text(AppStrings.addButton));
    await tester.pump();

    expect(repository.addedUserIds, ['10']);
    expect(find.text(AppStrings.requestedLabel), findsOneWidget);
    expect(find.text(AppStrings.addButton), findsNothing);
  });

  testWidgets('tapping a search result row opens their profile with Add to friends', (tester) async {
    await _pumpAddFriend(tester);

    await _search(tester, 'sardor');
    await tester.tap(find.text('Sardor Aliyev'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerDetailScreen), findsOneWidget);
    expect(find.text(AppStrings.addToFriendsButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing the search restores the invite section', (tester) async {
    await _pumpAddFriend(tester);

    await _search(tester, 'sardor');
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pump();

    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
    expect(find.text('Sardor Aliyev'), findsNothing);
  });

  testWidgets('tapping "Share the link" shows a coming-soon snackbar', (tester) async {
    await _pumpAddFriend(tester);

    await tester.tap(find.text(AppStrings.shareLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppStrings.comingSoon), findsOneWidget);
  });

  testWidgets('the back button returns to Friends when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpAddFriend(tester);
    router.go(AppRoutes.friends);
    unawaited(router.push(AppRoutes.addFriend));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addFriend), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    // "Or via invite link" now also appears on FriendsScreen itself (the
    // invite section moved there too) - AddFriendScreen's own title is
    // what actually distinguishes "we've left this screen".
    expect(find.text(AppStrings.addFriend), findsNothing);
  });
}
