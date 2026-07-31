import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/lobby_final_result.dart';
import '../../domain/entities/lobby_game_started_info.dart';
import '../../domain/entities/lobby_join_error.dart';
import '../../domain/entities/lobby_question_event.dart';
import '../../domain/entities/lobby_question_result.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../../domain/repositories/lobby_repository.dart';
import '../datasources/lobby_socket_data_source.dart';
import '../models/lobby_final_result_model.dart';
import '../models/lobby_game_started_info_model.dart';
import '../models/lobby_question_event_model.dart';
import '../models/lobby_question_result_model.dart';
import '../models/lobby_room_state_model.dart';

/// A thin real-time channel, not a REST resource — deliberately skips
/// the usual usecase-per-call layer (there's no orchestration beyond
/// forwarding a message and remapping raw JSON to entities).
class LobbyRepositoryImpl implements LobbyRepository {
  const LobbyRepositoryImpl(this._dataSource);

  final LobbySocketDataSource _dataSource;

  @override
  Stream<bool> get connectionStatus => _dataSource.connectionStatus;

  @override
  Stream<LobbyRoomState> get roomUpdates =>
      _dataSource.roomUpdate.map((json) => LobbyRoomStateModel.fromJson(json).toEntity());

  @override
  Stream<LobbyJoinErrorReason> get joinErrors => _dataSource.joinError.map(
        (json) => switch (json['reason'] as String?) {
          'room_full' => LobbyJoinErrorReason.roomFull,
          'already_started' => LobbyJoinErrorReason.alreadyStarted,
          _ => LobbyJoinErrorReason.notFound,
        },
      );

  @override
  Stream<String> get roomClosed => _dataSource.closed.map((json) => json['room_id'] as String);

  @override
  Stream<LobbyGameStartedInfo> get gameStarted =>
      _dataSource.gameStarted.map((json) => LobbyGameStartedInfoModel.fromJson(json).toEntity());

  @override
  Stream<LobbyQuestionEvent> get gameQuestion =>
      _dataSource.question.map((json) => LobbyQuestionEventModel.fromJson(json).toEntity());

  @override
  Stream<String> get waitingForOthers =>
      _dataSource.waitingForOthers.map((json) => json['room_id'] as String);

  @override
  Stream<LobbyQuestionResult> get gameQuestionResult =>
      _dataSource.questionResult.map((json) => LobbyQuestionResultModel.fromJson(json).toEntity());

  @override
  Stream<LobbyFinalResult> get gameFinished =>
      _dataSource.gameFinished.map((json) => LobbyFinalResultModel.fromJson(json).toEntity());

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  void disconnect() => _dataSource.disconnect();

  @override
  void createRoom() => unawaited(_dataSource.send({'type': 'lobby_create'}));

  @override
  void joinRoom(String roomCode) =>
      unawaited(_dataSource.send({'type': 'lobby_join', 'room_code': roomCode}));

  @override
  void leaveRoom(String roomId) => unawaited(_dataSource.send({'type': 'lobby_leave', 'room_id': roomId}));

  @override
  void startGame({required String roomId, required int categoryId, int? questionCount}) => unawaited(
        _dataSource.send({
          'type': 'lobby_start',
          'room_id': roomId,
          'category_id': categoryId,
          'question_count': questionCount,
        }),
      );

  @override
  void submitAnswer({required String roomId, required int questionIndex, required int? selectedOption}) =>
      unawaited(_dataSource.send({
        'type': 'lobby_answer',
        'room_id': roomId,
        'question_index': questionIndex,
        'selected_option': selectedOption,
      }));
}

final Provider<LobbyRepository> lobbyRepositoryProvider = Provider<LobbyRepository>(
  (ref) => LobbyRepositoryImpl(ref.watch(lobbySocketDataSourceProvider)),
);
