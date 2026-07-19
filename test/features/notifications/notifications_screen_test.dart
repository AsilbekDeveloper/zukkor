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
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:zukkor/features/notifications/domain/entities/notification_record.dart';
import 'package:zukkor/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta notifications repository — real
/// `GET /notifications` javobiga mos, 5 ta namunali yozuv (3 tasi
/// o'qilmagan, mos ravishda uy sahifadagi qizil nuqta ham ko'rinadi).
class _FakeNotificationsRepository implements NotificationsRepository {
  bool markAllReadCalled = false;

  @override
  Future<List<NotificationRecord>> getNotifications() async => [
        NotificationRecord(
          id: '1',
          kind: NotificationKind.duelChallenge,
          createdAt: DateTime.now(),
          isRead: false,
        ),
        NotificationRecord(
          id: '2',
          kind: NotificationKind.streakReminder,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: false,
        ),
        NotificationRecord(
          id: '3',
          kind: NotificationKind.top50,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: false,
        ),
        NotificationRecord(
          id: '4',
          kind: NotificationKind.friendRequest,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
        NotificationRecord(
          id: '5',
          kind: NotificationKind.welcome,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isRead: true,
        ),
      ];

  @override
  Future<void> markAllRead() async {
    markAllReadCalled = true;
  }
}

/// Backendga murojaat qilmaydigan soxta friends repository — bo'sh
/// ro'yxatlar qaytaradi (aks holda Friend Requests ekrani abadiy
/// "yuklanmoqda" spinnerida qolib, `pumpAndSettle` hech qachon tinchimaydi).
class _FakeFriendsRepository implements FriendsRepository {
  @override
  Future<List<Friend>> getFriends() async => const [];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) async => const [];

  @override
  Future<void> sendFriendRequest(String userId) async {}

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) async {}

  @override
  Future<void> declineFriendRequest(String requestId) async {}
}

Future<({GoRouter router, _FakeNotificationsRepository repository})> _pumpNotifications(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeNotificationsRepository repository = _FakeNotificationsRepository();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.friendRequests, builder: (context, state) => const FriendRequestsScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        notificationsRepositoryProvider.overrideWithValue(repository),
        friendsRepositoryProvider.overrideWithValue(_FakeFriendsRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.notifications));
  await tester.pumpAndSettle();
  return (router: router, repository: repository);
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

  testWidgets('opening the screen marks every notification read', (tester) async {
    final result = await _pumpNotifications(tester);

    expect(result.repository.markAllReadCalled, isTrue);
  });

  testWidgets('tapping a non-friend-request row shows a coming-soon snackbar', (tester) async {
    await _pumpNotifications(tester);

    // A real incoming duel challenge no longer opens from this list — it
    // arrives live over the duel WebSocket instead (see home_screen_test).
    await tester.tap(find.text(AppStrings.notifDuelChallenge));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppStrings.comingSoon), findsOneWidget);
  });

  testWidgets('tapping a friend-request row opens Friend Requests', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.text(AppStrings.notifFriendRequest));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.friendRequestsTitle), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpNotifications(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(NotificationsScreen), findsNothing);
  });
}
