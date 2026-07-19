import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/duel_final_result.dart';
import '../../domain/entities/duel_invite.dart';
import '../../domain/entities/duel_invite_outcome.dart';
import '../../domain/entities/duel_opponent_answered_event.dart';
import '../../domain/entities/duel_question_event.dart';
import '../../domain/entities/duel_question_result.dart';
import '../../domain/entities/duel_started_info.dart';
import '../../domain/repositories/duel_repository.dart';
import '../datasources/duel_socket_data_source.dart';
import '../models/duel_final_result_model.dart';
import '../models/duel_invite_model.dart';
import '../models/duel_question_event_model.dart';
import '../models/duel_question_result_model.dart';
import '../models/duel_started_info_model.dart';

/// A thin real-time channel, not a REST resource — deliberately skips
/// the usual usecase-per-call layer (there's no orchestration beyond
/// forwarding a message and remapping raw JSON to entities).
class DuelRepositoryImpl implements DuelRepository {
  DuelRepositoryImpl(this._dataSource) {
    _dataSource.inviteAck.listen(_handleAck);
    _dataSource.inviteAccepted.listen((json) => _handleOutcome(json, DuelInviteOutcomeStatus.accepted));
    _dataSource.inviteDeclined.listen((json) => _handleOutcome(json, DuelInviteOutcomeStatus.declined));
    _dataSource.inviteExpired.listen((json) => _handleOutcome(json, DuelInviteOutcomeStatus.expired));
  }

  final DuelSocketDataSource _dataSource;

  // The server's own invite id isn't known until the ack arrives, so
  // later accept/decline/expire events (keyed by that server id) are
  // mapped back to the client-generated id the caller already has.
  final Map<String, String> _clientInviteIdByServerId = {};
  final StreamController<DuelInviteOutcome> _outcomeController = StreamController<DuelInviteOutcome>.broadcast();

  void _handleAck(Map<String, dynamic> json) {
    final String? clientId = json['client_invite_id'] as String?;
    final String? serverId = json['invite_id'] as String?;
    if (clientId != null && serverId != null) {
      _clientInviteIdByServerId[serverId] = clientId;
    }
  }

  void _handleOutcome(Map<String, dynamic> json, DuelInviteOutcomeStatus status) {
    final String? serverId = json['invite_id'] as String?;
    final String? clientId = serverId == null ? null : _clientInviteIdByServerId[serverId];
    if (clientId == null) return;
    _outcomeController.add(DuelInviteOutcome(clientInviteId: clientId, status: status));
  }

  @override
  Stream<bool> get connectionStatus => _dataSource.connectionStatus;

  @override
  Stream<DuelInvite> get incomingInvites =>
      _dataSource.inviteReceived.map((json) => DuelInviteModel.fromJson(json).toEntity());

  @override
  Stream<DuelInviteOutcome> get outgoingInviteOutcomes => _outcomeController.stream;

  @override
  Stream<DuelStartedInfo> get duelStarted =>
      _dataSource.duelStarted.map((json) => DuelStartedInfoModel.fromJson(json).toEntity());

  @override
  Stream<DuelQuestionEvent> get duelQuestion =>
      _dataSource.duelQuestion.map((json) => DuelQuestionEventModel.fromJson(json).toEntity());

  @override
  Stream<DuelOpponentAnsweredEvent> get opponentAnswered => _dataSource.opponentAnswered.map(
        (json) => DuelOpponentAnsweredEvent(
          duelId: json['duel_id'] as String,
          questionIndex: json['question_index'] as int,
        ),
      );

  @override
  Stream<DuelQuestionResult> get duelQuestionResult =>
      _dataSource.duelQuestionResult.map((json) => DuelQuestionResultModel.fromJson(json).toEntity());

  @override
  Stream<DuelFinalResult> get duelFinished =>
      _dataSource.duelFinished.map((json) => DuelFinalResultModel.fromJson(json).toEntity());

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  void disconnect() => _dataSource.disconnect();

  @override
  void sendInvite({required String toUserId, required int categoryId, required String clientInviteId}) {
    _dataSource.send({
      'type': 'duel_invite',
      'client_invite_id': clientInviteId,
      'to_user_id': toUserId,
      'category_id': categoryId,
    });
  }

  @override
  void respondToInvite({required String inviteId, required bool accept}) {
    _dataSource.send({
      'type': 'duel_invite_respond',
      'invite_id': inviteId,
      'accept': accept,
    });
  }

  @override
  void submitAnswer({required String duelId, required int questionIndex, required int? selectedOption}) {
    _dataSource.send({
      'type': 'duel_answer',
      'duel_id': duelId,
      'question_index': questionIndex,
      'selected_option': selectedOption,
    });
  }
}

final Provider<DuelRepository> duelRepositoryProvider = Provider<DuelRepository>(
  (ref) => DuelRepositoryImpl(ref.watch(duelSocketDataSourceProvider)),
);
