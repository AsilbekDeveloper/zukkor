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
import 'package:zukkor/features/duel/data/repositories/duel_repository_impl.dart';
import 'package:zukkor/features/duel/domain/entities/duel_final_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite_outcome.dart';
import 'package:zukkor/features/duel/domain/entities/duel_opponent_progress_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_participant.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_started_info.dart';
import 'package:zukkor/features/duel/domain/repositories/duel_repository.dart';
import 'package:zukkor/features/duel/presentation/screens/duel_game_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_invite_screen.dart';
import 'package:zukkor/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:zukkor/features/notifications/domain/entities/notification_record.dart';
import 'package:zukkor/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/i18n/strings.g.dart';

final DuelInvite _invite = DuelInvite(
  id: 'invite-1',
  fromUser: const DuelParticipant(
    id: 'u1',
    username: 'malika_yusupova',
    firstName: 'Malika',
    lastName: 'Yusupova',
    avatarColor: 'a-teal',
    avatarImagePath: null,
  ),
  category: const Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
  expiresAt: DateTime(2026, 7, 19),
);

/// Backendga murojaat qilmaydigan soxta duel repository — Duel Invite
/// ekrani haqiqiy WebSocket'ga ulanmasligi kerak. `respond` chaqiruvlarini
/// tekshirish uchun yozib boradi.
class _FakeDuelRepository implements DuelRepository {
  final List<({String inviteId, bool accept})> respondCalls = [];

  @override
  Stream<bool> get connectionStatus => const Stream.empty();

  @override
  Stream<DuelInvite> get incomingInvites => const Stream.empty();

  @override
  Stream<DuelInviteOutcome> get outgoingInviteOutcomes => const Stream.empty();

  @override
  Stream<DuelStartedInfo> get duelStarted => const Stream.empty();

  @override
  Stream<DuelQuestionEvent> get duelQuestion => const Stream.empty();

  @override
  Stream<DuelOpponentProgressEvent> get opponentProgress => const Stream.empty();

  @override
  Stream<DuelQuestionResult> get duelQuestionResult => const Stream.empty();

  @override
  Stream<String> get waitingForOpponent => const Stream.empty();

  @override
  Stream<DuelFinalResult> get duelFinished => const Stream.empty();

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void sendInvite({
    required String toUserId,
    required int categoryId,
    required String clientInviteId,
    int? questionCount,
  }) {}

  @override
  void respondToInvite({required String inviteId, required bool accept}) {
    respondCalls.add((inviteId: inviteId, accept: accept));
  }

  @override
  void submitAnswer({required String duelId, required int questionIndex, required int? selectedOption}) {}
}

/// Backendga murojaat qilmaydigan soxta notifications repository — bo'sh
/// ro'yxat qaytaradi (aks holda Notifications ekrani abadiy "yuklanmoqda"
/// spinnerida qolib, uning ustiga qurilgan boshqa ekranlar
/// `pumpAndSettle` bilan hech qachon tinchimaydi).
class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<NotificationRecord>> getNotifications() async => const [];

  @override
  Future<void> markAllRead() async {}
}

Future<GoRouter> _pumpDuelInvite(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  DuelRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.notifications,
    routes: [
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(
        path: AppRoutes.duelInvite,
        builder: (context, state) => DuelInviteScreen(invite: state.extra! as DuelInvite),
      ),
      GoRoute(
        path: AppRoutes.duelGame,
        builder: (context, state) => const DuelGameScreen(),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        duelRepositoryProvider.overrideWithValue(repository ?? _FakeDuelRepository()),
        notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.duelInvite, extra: _invite));
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

  testWidgets('tapping "Accept" tells the server and opens the Duel game screen', (tester) async {
    final _FakeDuelRepository repository = _FakeDuelRepository();
    await _pumpDuelInvite(tester, repository: repository);

    await tester.tap(find.text(AppStrings.acceptButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(repository.respondCalls, [(inviteId: 'invite-1', accept: true)]);
    expect(find.byType(DuelGameScreen), findsOneWidget);
  });

  testWidgets('tapping "Decline" tells the server and returns to Notifications', (tester) async {
    final _FakeDuelRepository repository = _FakeDuelRepository();
    await _pumpDuelInvite(tester, repository: repository);

    await tester.tap(find.text(AppStrings.declineButton));
    await tester.pumpAndSettle();

    expect(repository.respondCalls, [(inviteId: 'invite-1', accept: false)]);
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byType(DuelInviteScreen), findsNothing);
  });

  testWidgets('the close button declines and returns to Notifications', (tester) async {
    final _FakeDuelRepository repository = _FakeDuelRepository();
    await _pumpDuelInvite(tester, repository: repository);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(repository.respondCalls, [(inviteId: 'invite-1', accept: false)]);
    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byType(DuelInviteScreen), findsNothing);
  });
}
