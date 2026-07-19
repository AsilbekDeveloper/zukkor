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
import 'package:zukkor/core/widgets/app_button.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/lobby/data/repositories/lobby_repository_impl.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_answer_progress.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_final_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_game_started_info.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_join_error.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_participant.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_event.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_room_state.dart';
import 'package:zukkor/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/lobby/presentation/widgets/code_input_row.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta lobby repository — [joinRoom]
/// chaqiruvini yozib boradi va [emitRoom]/[emitError] orqali server
/// javobini simulyatsiya qilish imkonini beradi.
class _FakeLobbyRepository implements LobbyRepository {
  final StreamController<LobbyRoomState> _roomController = StreamController<LobbyRoomState>.broadcast();
  final StreamController<LobbyJoinErrorReason> _joinErrorController =
      StreamController<LobbyJoinErrorReason>.broadcast();

  String? lastJoinedCode;

  @override
  Stream<bool> get connectionStatus => const Stream.empty();

  @override
  Stream<LobbyRoomState> get roomUpdates => _roomController.stream;

  @override
  Stream<LobbyJoinErrorReason> get joinErrors => _joinErrorController.stream;

  @override
  Stream<String> get roomClosed => const Stream.empty();

  @override
  Stream<LobbyGameStartedInfo> get gameStarted => const Stream.empty();

  @override
  Stream<LobbyQuestionEvent> get gameQuestion => const Stream.empty();

  @override
  Stream<LobbyAnswerProgress> get answerProgress => const Stream.empty();

  @override
  Stream<LobbyQuestionResult> get gameQuestionResult => const Stream.empty();

  @override
  Stream<LobbyFinalResult> get gameFinished => const Stream.empty();

  @override
  void startGame({required String roomId, required int categoryId}) {}

  @override
  void submitAnswer({required String roomId, required int questionIndex, required int? selectedOption}) {}

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void createRoom() {}

  @override
  void joinRoom(String roomCode) {
    lastJoinedCode = roomCode;
  }

  @override
  void leaveRoom(String roomId) {}

  void emitRoom() => _roomController.add(
        const LobbyRoomState(
          roomId: 'room-1',
          roomCode: '482913',
          youParticipantId: 'guest-1',
          participants: [
            LobbyParticipant(
              id: 'guest-1',
              username: null,
              firstName: null,
              lastName: null,
              avatarColor: null,
              avatarImagePath: null,
              isHost: false,
            ),
          ],
        ),
      );

  void emitError(LobbyJoinErrorReason reason) => _joinErrorController.add(reason);
}

Future<({GoRouter router, _FakeLobbyRepository repository})> _pumpJoinCode(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeLobbyRepository repository = _FakeLobbyRepository();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.joinCode, builder: (context, state) => const JoinCodeScreen()),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        lobbyRepositoryProvider.overrideWithValue(repository),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.joinCode));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return (router: router, repository: repository);
}

Future<void> _enterCode(WidgetTester tester, String code, {int startIndex = 0}) async {
  for (int i = 0; i < code.length; i++) {
    await tester.enterText(find.byType(TextField).at(startIndex + i), code[i]);
    await tester.pump();
  }
}

void main() {
  testWidgets('renders the hint, 6 code boxes and Join button, no overflow', (tester) async {
    await _pumpJoinCode(tester);

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(CodeInputRow.digitCount));
    expect(find.text(AppStrings.joinButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpJoinCode(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing a digit auto-advances focus to the next box', (tester) async {
    await _pumpJoinCode(tester);

    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.pump();

    final TextField secondBox = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(secondBox.focusNode!.hasFocus, isTrue);
  });

  testWidgets('the Join button stays disabled until all 6 digits are entered', (tester) async {
    await _pumpJoinCode(tester);

    await _enterCode(tester, '4829');
    final AppButton buttonBefore = tester.widget<AppButton>(find.byType(AppButton));
    expect(buttonBefore.onPressed, isNull);

    await _enterCode(tester, '13', startIndex: 4);
    final AppButton buttonAfter = tester.widget<AppButton>(find.byType(AppButton));
    expect(buttonAfter.onPressed, isNotNull);
  });

  testWidgets('tapping "Join" sends a real join request and navigates once the room arrives', (tester) async {
    final result = await _pumpJoinCode(tester);
    await _enterCode(tester, '482913');

    await tester.tap(find.text(AppStrings.joinButton));
    result.repository.emitRoom();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(result.repository.lastJoinedCode, '482913');
    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.waitingForHostLabel), findsOneWidget);
  });

  testWidgets('shows an error message when the room is not found', (tester) async {
    final result = await _pumpJoinCode(tester);
    await _enterCode(tester, '000000');

    await tester.tap(find.text(AppStrings.joinButton));
    result.repository.emitError(LobbyJoinErrorReason.notFound);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.roomNotFound), findsOneWidget);
    expect(find.byType(JoinCodeScreen), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final result = await _pumpJoinCode(tester);
    result.router.go(AppRoutes.home);
    unawaited(result.router.push(AppRoutes.joinCode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.joinCodeHint), findsNothing);
  });
}
