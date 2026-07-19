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
import 'package:zukkor/features/duel/data/repositories/duel_repository_impl.dart';
import 'package:zukkor/features/duel/domain/entities/duel_final_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite_outcome.dart';
import 'package:zukkor/features/duel/domain/entities/duel_opponent_answered_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_started_info.dart';
import 'package:zukkor/features/duel/domain/repositories/duel_repository.dart';
import 'package:zukkor/features/duel/presentation/screens/duel_game_screen.dart';
import 'package:zukkor/features/friends/presentation/models/duel_match.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_waiting_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/i18n/strings.g.dart';

const FriendEntry _opponent = FriendEntry(
  id: 'u1',
  name: 'Malika Yusupova',
  username: 'malika_yusupova',
  initials: 'MR',
  avatarColor: AvatarColorOption.teal,
);
const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 120,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);
const DuelMatch _match = DuelMatch(opponent: _opponent, category: _math);

/// Backendga murojaat qilmaydigan soxta duel repository — Duel Waiting
/// ekrani haqiqiy WebSocket'ga ulanmasligi kerak. [emitOutcome] test'ga
/// serverdan "qabul qilindi/rad etildi/muddati tugadi" xabari kelganini
/// simulyatsiya qilish imkonini beradi.
class _FakeDuelRepository implements DuelRepository {
  final StreamController<DuelInviteOutcome> _outcomeController = StreamController<DuelInviteOutcome>.broadcast();

  String? lastClientInviteId;
  String? lastToUserId;
  int? lastCategoryId;

  @override
  Stream<bool> get connectionStatus => const Stream.empty();

  @override
  Stream<DuelInvite> get incomingInvites => const Stream.empty();

  @override
  Stream<DuelInviteOutcome> get outgoingInviteOutcomes => _outcomeController.stream;

  @override
  Stream<DuelStartedInfo> get duelStarted => const Stream.empty();

  @override
  Stream<DuelQuestionEvent> get duelQuestion => const Stream.empty();

  @override
  Stream<DuelOpponentAnsweredEvent> get opponentAnswered => const Stream.empty();

  @override
  Stream<DuelQuestionResult> get duelQuestionResult => const Stream.empty();

  @override
  Stream<DuelFinalResult> get duelFinished => const Stream.empty();

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void sendInvite({required String toUserId, required int categoryId, required String clientInviteId}) {
    lastClientInviteId = clientInviteId;
    lastToUserId = toUserId;
    lastCategoryId = categoryId;
  }

  @override
  void respondToInvite({required String inviteId, required bool accept}) {}

  @override
  void submitAnswer({required String duelId, required int questionIndex, required int? selectedOption}) {}

  void emitOutcome(DuelInviteOutcomeStatus status) {
    final String? clientId = lastClientInviteId;
    if (clientId == null) return;
    _outcomeController.add(DuelInviteOutcome(clientInviteId: clientId, status: status));
  }
}

Future<({GoRouter router, _FakeDuelRepository repository})> _pumpDuelWaiting(
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
        path: AppRoutes.duelWaiting,
        builder: (context, state) => DuelWaitingScreen(match: state.extra! as DuelMatch),
      ),
      GoRoute(
        path: AppRoutes.duelGame,
        builder: (context, state) => const DuelGameScreen(),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeDuelRepository repository = _FakeDuelRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        duelRepositoryProvider.overrideWithValue(repository),
      ],
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
  return (router: router, repository: repository);
}

void main() {
  testWidgets('sends a real invite and renders the opponent, category and waiting indicator, no overflow',
      (tester) async {
    final result = await _pumpDuelWaiting(tester);

    expect(result.repository.lastToUserId, 'u1');
    expect(result.repository.lastCategoryId, _math.id);
    expect(find.text(AppStrings.duelWaitingTitle), findsOneWidget);
    expect(find.text('Malika Yusupova'), findsOneWidget);
    // Home stays mounted underneath (pushed on top of it) and has its own
    // "Math" category tile, so at least one match is enough here.
    expect(find.text('Math'), findsWidgets);
    expect(find.text(AppStrings.waitingForAcceptLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpDuelWaiting(tester, size: const Size(360, 780));

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('once the opponent accepts, opens the Duel game screen', (tester) async {
    final result = await _pumpDuelWaiting(tester);

    result.repository.emitOutcome(DuelInviteOutcomeStatus.accepted);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DuelGameScreen), findsOneWidget);
  });

  testWidgets('if the opponent declines, shows a message and a way back', (tester) async {
    final result = await _pumpDuelWaiting(tester);

    result.repository.emitOutcome(DuelInviteOutcomeStatus.declined);
    await tester.pump();

    expect(find.text(AppStrings.duelDeclinedLabel), findsOneWidget);
    expect(find.text(AppStrings.duelWaitingBackToHome), findsOneWidget);
  });

  testWidgets('if the invite expires, shows a message and a way back', (tester) async {
    final result = await _pumpDuelWaiting(tester);

    result.repository.emitOutcome(DuelInviteOutcomeStatus.expired);
    await tester.pump();

    expect(find.text(AppStrings.duelExpiredLabel), findsOneWidget);
    expect(find.text(AppStrings.duelWaitingBackToHome), findsOneWidget);
  });

  testWidgets('the close button returns to Home when pushed on top of it', (tester) async {
    await _pumpDuelWaiting(tester);

    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(DuelWaitingScreen), findsNothing);
  });
}
