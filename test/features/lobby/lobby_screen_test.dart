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
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/widgets/leaderboard_podium.dart';
import 'package:zukkor/features/lobby/data/repositories/lobby_repository_impl.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_final_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_game_started_info.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_join_error.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_participant.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_player_score.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_event.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_room_state.dart';
import 'package:zukkor/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:zukkor/features/lobby/presentation/controllers/lobby_controller.dart';
import 'package:zukkor/features/lobby/presentation/models/lobby_result_args.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_game_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_result_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/features/quiz/presentation/widgets/answer_button.dart';
import 'package:zukkor/i18n/strings.g.dart';

const List<LobbyParticipant> _otherParticipants = [
  LobbyParticipant(
    id: 'host-1',
    username: 'aziz',
    firstName: 'Aziz',
    lastName: null,
    avatarColor: 'a-coral',
    avatarImagePath: null,
    isHost: true,
  ),
  LobbyParticipant(
    id: 'u2',
    username: 'malika',
    firstName: 'Malika',
    lastName: null,
    avatarColor: 'a-teal',
    avatarImagePath: null,
    isHost: false,
  ),
  LobbyParticipant(
    id: 'u3',
    username: 'shohruh',
    firstName: 'Shohruh',
    lastName: null,
    avatarColor: 'a-terra',
    avatarImagePath: null,
    isHost: false,
  ),
  LobbyParticipant(
    id: 'u4',
    username: 'dilnoza',
    firstName: 'Dilnoza',
    lastName: null,
    avatarColor: 'a-pink',
    avatarImagePath: null,
    isHost: false,
  ),
];

const LobbyParticipant _guestSelf = LobbyParticipant(
  id: 'guest-1',
  username: null,
  firstName: null,
  lastName: null,
  avatarColor: null,
  avatarImagePath: null,
  isHost: false,
);

const Category _mathCategory =
    Category(id: 1, name: 'Math', iconName: 'math-symbols', colorKey: 'coral', questionCount: 120);

/// Backendga murojaat qilmaydigan soxta quiz repository — CategoriesScreen
/// (xona o'yinini boshlash uchun kategoriya tanlagich sifatida ham
/// ishlatiladi) `GET /categories`ga real murojaat qilmasligi kerak.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => const [_mathCategory];

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) =>
      throw UnimplementedError();

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> reportQuestion({required int questionId, required String reason, String? comment}) =>
      throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta lobby repository — real xona
/// yaratish/qo'shilish/o'yinni simulyatsiya qiladi: [createRoom] darhol
/// xost sifatida, [joinRoom] darhol mehmon sifatida to'liq roster
/// yuboradi; [startGame] bitta savolli qisqa o'yinni avtomatik yuritadi
/// (savol → [submitAnswer] chaqirilganda natija + yakun).
class _FakeLobbyRepository implements LobbyRepository {
  final StreamController<LobbyRoomState> _roomController = StreamController<LobbyRoomState>.broadcast();
  final StreamController<LobbyJoinErrorReason> _joinErrorController =
      StreamController<LobbyJoinErrorReason>.broadcast();
  final StreamController<String> _closedController = StreamController<String>.broadcast();
  final StreamController<LobbyGameStartedInfo> _gameStartedController =
      StreamController<LobbyGameStartedInfo>.broadcast();
  final StreamController<LobbyQuestionEvent> _questionController =
      StreamController<LobbyQuestionEvent>.broadcast();
  final StreamController<String> _waitingForOthersController = StreamController<String>.broadcast();
  final StreamController<LobbyQuestionResult> _questionResultController =
      StreamController<LobbyQuestionResult>.broadcast();
  final StreamController<LobbyFinalResult> _gameFinishedController =
      StreamController<LobbyFinalResult>.broadcast();

  String? lastLeftRoomId;
  int? lastStartedCategoryId;

  @override
  Stream<bool> get connectionStatus => const Stream.empty();

  @override
  Stream<LobbyRoomState> get roomUpdates => _roomController.stream;

  @override
  Stream<LobbyJoinErrorReason> get joinErrors => _joinErrorController.stream;

  @override
  Stream<String> get roomClosed => _closedController.stream;

  @override
  Stream<LobbyGameStartedInfo> get gameStarted => _gameStartedController.stream;

  @override
  Stream<LobbyQuestionEvent> get gameQuestion => _questionController.stream;

  @override
  Stream<String> get waitingForOthers => _waitingForOthersController.stream;

  @override
  Stream<LobbyQuestionResult> get gameQuestionResult => _questionResultController.stream;

  @override
  Stream<LobbyFinalResult> get gameFinished => _gameFinishedController.stream;

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void createRoom() {
    _roomController.add(
      const LobbyRoomState(
        roomId: 'room-1',
        roomCode: '482913',
        youParticipantId: 'host-1',
        participants: _otherParticipants,
      ),
    );
  }

  @override
  void joinRoom(String roomCode) {
    _roomController.add(
      const LobbyRoomState(
        roomId: 'room-1',
        roomCode: '482913',
        youParticipantId: 'guest-1',
        participants: [..._otherParticipants, _guestSelf],
      ),
    );
  }

  @override
  void leaveRoom(String roomId) {
    lastLeftRoomId = roomId;
  }

  @override
  void startGame({required String roomId, required int categoryId, int? questionCount}) {
    lastStartedCategoryId = categoryId;
    _gameStartedController.add(
      const LobbyGameStartedInfo(roomId: 'room-1', category: _mathCategory, totalQuestions: 1),
    );
    _questionController.add(
      const LobbyQuestionEvent(
        roomId: 'room-1',
        questionIndex: 0,
        question: LobbyQuestion(text: '2 + 2 = ?', options: ['3', '4', '5', '6'], correctOption: 1, timeLimitMs: 15000),
      ),
    );
  }

  @override
  void submitAnswer({required String roomId, required int questionIndex, required int? selectedOption}) {
    _questionResultController.add(
      const LobbyQuestionResult(
        roomId: 'room-1',
        questionIndex: 0,
        correctOption: 1,
        yourSelectedOption: 1,
        yourCorrect: true,
      ),
    );
    _gameFinishedController.add(
      const LobbyFinalResult(
        roomId: 'room-1',
        standings: [
          LobbyPlayerScore(participantId: 'host-1', correct: 1, total: 1, totalTimeMs: 1000),
          LobbyPlayerScore(participantId: 'u2', correct: 1, total: 1, totalTimeMs: 1200),
          LobbyPlayerScore(participantId: 'u3', correct: 0, total: 1, totalTimeMs: 1500),
          LobbyPlayerScore(participantId: 'u4', correct: 0, total: 1, totalTimeMs: 1600),
        ],
        xpEarned: 15,
        ballEarned: 900,
        breakdown: [],
      ),
    );
  }

  void emitClosed(String roomId) => _closedController.add(roomId);
}

Future<({GoRouter router, _FakeLobbyRepository repository})> _pumpLobby(
  WidgetTester tester, {
  required LobbyRole role,
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
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => CategoriesScreen(
          onCategoryPicked: (context, ref, category) {
            ref.read(lobbyControllerProvider.notifier).startGame(category.id);
            context.pop();
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.lobbyGame,
        builder: (context, state) => const LobbyGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.lobbyResult,
        builder: (context, state) => LobbyResultScreen(args: state.extra! as LobbyResultArgs),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeLobbyRepository repository = _FakeLobbyRepository();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      lobbyRepositoryProvider.overrideWithValue(repository),
      quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  // Let Home's initState connect() microtask run before joining, so the
  // controller is actually subscribed when the room update arrives.
  await tester.pump();

  // Guest screens are only ever reached in production after JoinCodeScreen
  // has already called joinRoom() and gotten a room back — simulate that
  // here rather than relying on LobbyScreen itself to join.
  if (role == LobbyRole.guest) {
    container.read(lobbyControllerProvider.notifier).joinRoom('482913');
  }

  unawaited(router.push(AppRoutes.lobby, extra: role));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return (router: router, repository: repository);
}

void main() {
  testWidgets('host: renders the room code, roster and Start button, no overflow', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host);

    expect(find.text(AppStrings.roomCodeLabel), findsOneWidget);
    expect(find.text('482913'), findsOneWidget);
    expect(find.text(AppStrings.playerCount(4, 20)), findsOneWidget);
    // The host's own roster entry shows the translated "You", not their
    // real name — matches how the guest's own entry is labeled too.
    expect(find.text(AppStrings.currentUserName), findsOneWidget);
    expect(find.text('Malika'), findsOneWidget);
    expect(find.text('Shohruh'), findsOneWidget);
    expect(find.text('Dilnoza'), findsOneWidget);
    expect(find.byIcon(TablerIcons.crown), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest: adds "You" to the roster and shows the waiting indicator', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.guest);

    expect(find.text(AppStrings.playerCount(5, 20)), findsOneWidget);
    expect(find.text(AppStrings.currentUserName), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host, size: const Size(360, 780));

    expect(find.text(AppStrings.roomCodeLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('host: "Start the game" opens the category picker', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host);

    await tester.tap(find.text(AppStrings.startGameButton));
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('the back button leaves the room and returns to Home when pushed on top of it', (tester) async {
    final result = await _pumpLobby(tester, role: LobbyRole.host);
    result.router.go(AppRoutes.home);
    unawaited(result.router.push(AppRoutes.lobby, extra: LobbyRole.host));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(result.repository.lastLeftRoomId, 'room-1');
    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.lobbyScreenTitle), findsNothing);
  });

  testWidgets('guest: when the host leaves, shows a message and returns to Home', (tester) async {
    final result = await _pumpLobby(tester, role: LobbyRole.guest);

    result.repository.emitClosed('room-1');
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(LobbyScreen), findsNothing);
  });

  testWidgets('host: picking a category starts the room game and syncs everyone into it', (tester) async {
    final result = await _pumpLobby(tester, role: LobbyRole.host);

    await tester.tap(find.text(AppStrings.startGameButton));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesScreen), findsOneWidget);

    await tester.tap(find.text('Math'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.repository.lastStartedCategoryId, 1);
    expect(find.byType(LobbyGameScreen), findsOneWidget);
    expect(find.text('2 + 2 = ?'), findsOneWidget);
  });

  testWidgets('host: answering the last question lands on the room results (leaderboard)', (tester) async {
    await _pumpLobby(tester, role: LobbyRole.host);

    await tester.tap(find.text(AppStrings.startGameButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Math'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(LobbyGameScreen), findsOneWidget);

    await tester.tap(find.byType(AnswerButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // A room leaderboard, not the plain solo Result screen.
    expect(find.byType(LobbyResultScreen), findsOneWidget);
    expect(find.text(AppStrings.lobbyResultTitle), findsOneWidget);
    expect(find.byType(LeaderboardPodium), findsOneWidget);
    // The room's real roster is ranked alongside "You" (the host).
    expect(find.text('Malika'), findsOneWidget);
    expect(find.text(AppStrings.currentUserName), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
