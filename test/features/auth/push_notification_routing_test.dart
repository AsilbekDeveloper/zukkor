import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zukkor/core/notifications/push_notification_service.dart';
import 'package:zukkor/core/router/app_router.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/features/auth/presentation/user_session.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite.dart';

/// Every push the backend sends now tags itself with `data: {"type":
/// "..."}` (`app/services/push.py`) - these tests drive
/// [pushNotificationHandlerProvider] end to end (fake tap -> real
/// router) to confirm each type actually opens the right screen,
/// instead of every push landing on the same generic destination like
/// before.
class _FakePushNotificationService extends PushNotificationService {
  final StreamController<RemoteMessage> _controller =
      StreamController<RemoteMessage>.broadcast();

  @override
  Stream<RemoteMessage> get onTap => _controller.stream;

  void emit(RemoteMessage message) => _controller.add(message);
}

Future<GoRouter> _pumpWithFakePush(
  WidgetTester tester,
  _FakePushNotificationService service,
) async {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const Scaffold(body: Text('HOME')),
      ),
      GoRoute(
        path: AppRoutes.friendRequests,
        builder: (_, _) => const Scaffold(body: Text('FRIEND_REQUESTS')),
      ),
      GoRoute(
        path: AppRoutes.myAiQuizzes,
        builder: (_, _) => const Scaffold(body: Text('MY_AI_QUIZZES')),
      ),
      GoRoute(
        path: AppRoutes.duelInvite,
        builder: (context, state) {
          final DuelInvite invite = state.extra! as DuelInvite;
          return Scaffold(body: Text('DUEL_INVITE:${invite.fromUser.id}'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pushNotificationServiceProvider.overrideWithValue(service),
        appRouterProvider.overrideWithValue(router),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          // Activates the listener - mirrors how ZukkorApp itself does
          // `ref.watch(pushNotificationHandlerProvider)`.
          ref.watch(pushNotificationHandlerProvider);
          return MaterialApp.router(routerConfig: router);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('friend_request push opens Friend Requests', (tester) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(const RemoteMessage(data: {'type': 'friend_request'}));
    await tester.pumpAndSettle();

    expect(find.text('FRIEND_REQUESTS'), findsOneWidget);
  });

  testWidgets('ai_quiz_ready push opens My AI Quizzes', (tester) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(
      const RemoteMessage(data: {'type': 'ai_quiz_ready', 'quiz_id': '5'}),
    );
    await tester.pumpAndSettle();

    expect(find.text('MY_AI_QUIZZES'), findsOneWidget);
  });

  testWidgets('ai_quiz_failed push also opens My AI Quizzes', (tester) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(const RemoteMessage(data: {'type': 'ai_quiz_failed'}));
    await tester.pumpAndSettle();

    expect(find.text('MY_AI_QUIZZES'), findsOneWidget);
  });

  testWidgets('streak_reminder push opens Home', (tester) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(const RemoteMessage(data: {'type': 'streak_reminder'}));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('a push with no recognized type falls back to Home', (
    tester,
  ) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(const RemoteMessage());
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets(
    'duel_challenge push parses the embedded invite and opens Duel Invite',
    (tester) async {
      final service = _FakePushNotificationService();
      await _pumpWithFakePush(tester, service);

      final String inviteJson = jsonEncode({
        'invite_id': 'inv1',
        'from_user': {
          'id': 'u9',
          'username': 'aziz',
          'first_name': 'Aziz',
          'last_name': 'Karimov',
          'avatar_color': 'a-coral',
          'avatar_image_path': null,
        },
        'category': {
          'id': 1,
          'name': 'Matematika',
          'icon_name': 'calculator',
          'color_key': 'coral',
          'question_count': 10,
        },
        'expires_at': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      });

      service.emit(
        RemoteMessage(data: {'type': 'duel_challenge', 'invite': inviteJson}),
      );
      await tester.pumpAndSettle();

      expect(find.text('DUEL_INVITE:u9'), findsOneWidget);
    },
  );

  testWidgets('duel_challenge push with malformed invite JSON does not crash', (
    tester,
  ) async {
    final service = _FakePushNotificationService();
    await _pumpWithFakePush(tester, service);

    service.emit(
      const RemoteMessage(
        data: {'type': 'duel_challenge', 'invite': 'not json'},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
