import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:zukkor/features/duel/presentation/controllers/duel_controller.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';

/// [DuelController]'s handling of `opponentDisconnected`/
/// `opponentReconnected` (2026-09-13, user request) - a dropped
/// connection now gets a server-side grace window instead of instantly
/// voiding the match; this drives the "raqibning aloqasi uzilgan"
/// banner on [DuelGameScreen] via [DuelGameState.opponentDisconnected].
class _FakeDuelRepository extends Fake implements DuelRepository {
  final StreamController<bool> _connection = StreamController<bool>.broadcast();
  final StreamController<DuelStartedInfo> _started =
      StreamController<DuelStartedInfo>.broadcast();
  final StreamController<String> _opponentDisconnected =
      StreamController<String>.broadcast();
  final StreamController<String> _opponentReconnected =
      StreamController<String>.broadcast();

  @override
  Stream<bool> get connectionStatus => _connection.stream;
  @override
  Stream<DuelInvite> get incomingInvites => const Stream.empty();
  @override
  Stream<DuelInviteOutcome> get outgoingInviteOutcomes => const Stream.empty();
  @override
  Stream<DuelStartedInfo> get duelStarted => _started.stream;
  @override
  Stream<DuelQuestionEvent> get duelQuestion => const Stream.empty();
  @override
  Stream<DuelOpponentProgressEvent> get opponentProgress =>
      const Stream.empty();
  @override
  Stream<DuelQuestionResult> get duelQuestionResult => const Stream.empty();
  @override
  Stream<String> get waitingForOpponent => const Stream.empty();
  @override
  Stream<DuelFinalResult> get duelFinished => const Stream.empty();
  @override
  Stream<String> get duelCancelled => const Stream.empty();
  @override
  Stream<String> get opponentDisconnected => _opponentDisconnected.stream;
  @override
  Stream<String> get opponentReconnected => _opponentReconnected.stream;

  @override
  Future<void> connect() async => _connection.add(true);

  void simulateDuelStarted(DuelStartedInfo info) => _started.add(info);
  void simulateOpponentDisconnected(String duelId) =>
      _opponentDisconnected.add(duelId);
  void simulateOpponentReconnected(String duelId) =>
      _opponentReconnected.add(duelId);
}

const _category = Category(
  id: 1,
  name: 'Math',
  questionCount: 10,
  iconName: 'calculator',
  colorKey: 'coral',
);
const _opponent = DuelParticipant(
  id: 'u2',
  username: 'ali',
  firstName: 'Ali',
  lastName: null,
  avatarColor: null,
  avatarImagePath: null,
);

void main() {
  late _FakeDuelRepository fakeRepo;
  late ProviderContainer container;

  setUp(() async {
    fakeRepo = _FakeDuelRepository();
    container = ProviderContainer(
      overrides: [duelRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);
    await container.read(duelControllerProvider.notifier).connect();
    fakeRepo.simulateDuelStarted(
      const DuelStartedInfo(
        duelId: 'duel-1',
        category: _category,
        totalQuestions: 5,
        opponent: _opponent,
      ),
    );
  });

  test('opponentDisconnected marks the game as opponentDisconnected', () async {
    fakeRepo.simulateOpponentDisconnected('duel-1');
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(duelControllerProvider).game?.opponentDisconnected,
      isTrue,
    );
  });

  test('opponentReconnected clears the flag again', () async {
    fakeRepo.simulateOpponentDisconnected('duel-1');
    await Future<void>.delayed(Duration.zero);
    fakeRepo.simulateOpponentReconnected('duel-1');
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(duelControllerProvider).game?.opponentDisconnected,
      isFalse,
    );
  });

  test('a mismatched duel id is ignored', () async {
    fakeRepo.simulateOpponentDisconnected('some-other-duel');
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(duelControllerProvider).game?.opponentDisconnected,
      isFalse,
    );
  });
}
