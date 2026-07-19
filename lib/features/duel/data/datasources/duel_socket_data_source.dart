import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/storage/token_storage.dart';

/// Raw connection to `/ws/duel` — demuxes incoming JSON messages by
/// their `type` field into separate broadcast streams of decoded maps.
/// Doesn't know about domain entities; that's [DuelRepositoryImpl]'s job.
class DuelSocketDataSource {
  DuelSocketDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _inviteReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _inviteAckController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _inviteAcceptedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _inviteDeclinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _inviteExpiredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelStartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelQuestionController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _opponentAnsweredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelQuestionResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelFinishedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<Map<String, dynamic>> get inviteReceived => _inviteReceivedController.stream;
  Stream<Map<String, dynamic>> get inviteAck => _inviteAckController.stream;
  Stream<Map<String, dynamic>> get inviteAccepted => _inviteAcceptedController.stream;
  Stream<Map<String, dynamic>> get inviteDeclined => _inviteDeclinedController.stream;
  Stream<Map<String, dynamic>> get inviteExpired => _inviteExpiredController.stream;
  Stream<Map<String, dynamic>> get duelStarted => _duelStartedController.stream;
  Stream<Map<String, dynamic>> get duelQuestion => _duelQuestionController.stream;
  Stream<Map<String, dynamic>> get opponentAnswered => _opponentAnsweredController.stream;
  Stream<Map<String, dynamic>> get duelQuestionResult => _duelQuestionResultController.stream;
  Stream<Map<String, dynamic>> get duelFinished => _duelFinishedController.stream;

  bool get isConnected => _channel != null;

  /// Never throws — a failed connect (no token yet, no network, the
  /// endpoint not being up) just leaves the duel features quietly
  /// inactive instead of crashing the caller, same as this app's other
  /// silent-catch data loads.
  Future<void> connect() async {
    if (_channel != null) return;
    try {
      final String? token = await _tokenStorage.readAccessToken();
      if (token == null) return;

      final Uri uri = Uri.parse('${AppConfig.wsBaseUrl}/ws/duel').replace(
        queryParameters: {'token': token},
      );

      final WebSocketChannel channel = WebSocketChannel.connect(uri);
      _channel = channel;

      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: () {
          _channel = null;
          _connectionController.add(false);
        },
        onError: (_) {
          _channel = null;
          _connectionController.add(false);
        },
      );
      _connectionController.add(true);
    } catch (_) {
      _channel = null;
      _connectionController.add(false);
    }
  }

  void _handleMessage(dynamic raw) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (json['type'] as String?) {
      case 'duel_invite_received':
        _inviteReceivedController.add(json);
      case 'duel_invite_ack':
        _inviteAckController.add(json);
      case 'duel_invite_accepted':
        _inviteAcceptedController.add(json);
      case 'duel_invite_declined':
        _inviteDeclinedController.add(json);
      case 'duel_invite_expired':
        _inviteExpiredController.add(json);
      case 'duel_started':
        _duelStartedController.add(json);
      case 'duel_question':
        _duelQuestionController.add(json);
      case 'duel_opponent_answered':
        _opponentAnsweredController.add(json);
      case 'duel_question_result':
        _duelQuestionResultController.add(json);
      case 'duel_finished':
        _duelFinishedController.add(json);
    }
  }

  void send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }
}

final Provider<DuelSocketDataSource> duelSocketDataSourceProvider = Provider<DuelSocketDataSource>(
  (ref) => DuelSocketDataSource(ref.watch(tokenStorageProvider)),
);
