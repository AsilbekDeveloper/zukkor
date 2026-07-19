import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/storage/token_storage.dart';

/// Raw connection to `/ws/lobby` — demuxes incoming JSON messages by
/// their `type` field into separate broadcast streams of decoded maps.
/// Doesn't know about domain entities; that's [LobbyRepositoryImpl]'s
/// job.
class LobbySocketDataSource {
  LobbySocketDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _roomUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _joinErrorController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _closedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _gameStartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _questionController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _answerProgressController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _questionResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _gameFinishedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<Map<String, dynamic>> get roomUpdate => _roomUpdateController.stream;
  Stream<Map<String, dynamic>> get joinError => _joinErrorController.stream;
  Stream<Map<String, dynamic>> get closed => _closedController.stream;
  Stream<Map<String, dynamic>> get gameStarted => _gameStartedController.stream;
  Stream<Map<String, dynamic>> get question => _questionController.stream;
  Stream<Map<String, dynamic>> get answerProgress => _answerProgressController.stream;
  Stream<Map<String, dynamic>> get questionResult => _questionResultController.stream;
  Stream<Map<String, dynamic>> get gameFinished => _gameFinishedController.stream;

  /// Never throws — a failed connect (no token yet, no network, the
  /// endpoint not being up) just leaves the lobby features quietly
  /// inactive instead of crashing the caller, same as this app's other
  /// silent-catch data loads.
  Future<void> connect() async {
    if (_channel != null) return;
    try {
      final String? token = await _tokenStorage.readAccessToken();
      if (token == null) return;

      final Uri uri = Uri.parse('${AppConfig.wsBaseUrl}/ws/lobby').replace(
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
      case 'lobby_room_update':
        _roomUpdateController.add(json);
      case 'lobby_join_error':
        _joinErrorController.add(json);
      case 'lobby_closed':
        _closedController.add(json);
      case 'lobby_game_started':
        _gameStartedController.add(json);
      case 'lobby_question':
        _questionController.add(json);
      case 'lobby_answer_progress':
        _answerProgressController.add(json);
      case 'lobby_question_result':
        _questionResultController.add(json);
      case 'lobby_game_finished':
        _gameFinishedController.add(json);
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

final Provider<LobbySocketDataSource> lobbySocketDataSourceProvider = Provider<LobbySocketDataSource>(
  (ref) => LobbySocketDataSource(ref.watch(tokenStorageProvider)),
);
