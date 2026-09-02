import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/state/game_status_provider.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/auth/presentation/controllers/current_user_controller.dart';
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
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:zukkor/features/notifications/domain/entities/notification_record.dart';
import 'package:zukkor/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeDuelRepository extends Fake implements DuelRepository {
  final StreamController<bool> _conn = StreamController<bool>.broadcast();
  final StreamController<DuelInvite> _invites = StreamController<DuelInvite>.broadcast();

  @override
  Stream<bool> get connectionStatus => _conn.stream;
  @override
  Stream<DuelInvite> get incomingInvites => _invites.stream;

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
  Stream<String> get duelCancelled => const Stream.empty();

  @override
  Future<void> connect() async => _conn.add(true);

  void simulateInvite(DuelInvite invite) => _invites.add(invite);
}

class _FakeNotificationsRepository extends Fake implements NotificationsRepository {
  @override
  Future<List<NotificationRecord>> getNotifications() async => [];
  
  @override
  Future<void> markAllRead() async {}
}

void main() {
  late _FakeDuelRepository duelRepo;

  setUp(() {
    duelRepo = _FakeDuelRepository();
    SharedPreferences.setMockInitialValues({});
  });

  final invite = DuelInvite(
    id: 'i1',
    fromUser: const DuelParticipant(
      id: 'u2',
      username: 'ali',
      firstName: 'Ali',
      lastName: null,
      avatarColor: null,
      avatarImagePath: null,
    ),
    category: const Category(
      id: 1,
      name: 'Math',
      iconName: 'math',
      colorKey: 'coral',
      questionCount: 10,
    ),
    expiresAt: DateTime.now().add(const Duration(minutes: 1)),
  );

  Future<void> pumpHome(WidgetTester tester, ProviderContainer container) async {
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
        GoRoute(path: AppRoutes.duelInvite, builder: (context, state) => const Scaffold(body: Text('INVITE_SCREEN'))),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('if NOT in game, incoming invite opens full-screen DuelInvite', (tester) async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
      duelRepositoryProvider.overrideWithValue(duelRepo),
      notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
      currentUserControllerProvider.overrideWith(() => CurrentUserController()),
    ]);
    
    await pumpHome(tester, container);

    duelRepo.simulateInvite(invite);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('INVITE_SCREEN'), findsOneWidget);
  });

  testWidgets('if IN game, incoming invite shows snackbar instead of opening screen', (tester) async {
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
      duelRepositoryProvider.overrideWithValue(duelRepo),
      notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
      currentUserControllerProvider.overrideWith(() => CurrentUserController()),
    ]);
    
    // Set "in game" state
    container.read(isInActiveGameProvider.notifier).setInGame(true);

    await pumpHome(tester, container);

    duelRepo.simulateInvite(invite);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Screen should NOT be opened
    expect(find.text('INVITE_SCREEN'), findsNothing);
    // Snackbar should be visible (contains sender's name)
    expect(find.textContaining('Ali'), findsOneWidget);
  });
}
