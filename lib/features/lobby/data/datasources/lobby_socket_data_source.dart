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
  Future<void>? _connecting;
  Timer? _keepAliveTimer;
  Timer? _healthCheckTimer;
  DateTime _lastActivityAt = DateTime.now();

  /// How often to send a no-op message to keep the connection alive.
  /// Render's proxy (and similar cloud reverse proxies) silently closes
  /// WebSocket connections that sit idle for a while, without either
  /// side seeing a clean close frame. Any traffic resets that idle
  /// timer, so this doesn't need to be a real ping/pong handshake.
  static const Duration _keepAliveInterval = Duration(seconds: 25);

  /// A connection can go "half-open" — this end still thinks it's
  /// connected (no `onDone`/`onError` ever fired) while the other side
  /// (or a proxy in between) has actually dropped it, so our own pings
  /// go nowhere and nothing ever arrives back either. Since a real ping
  /// goes out every [_keepAliveInterval], seeing NO traffic at all (not
  /// even the server's `pong`) for much longer than that means the
  /// socket is dead in practice even though it doesn't look it.
  static const Duration _deadConnectionThreshold = Duration(seconds: 70);

  static const Duration _healthCheckInterval = Duration(seconds: 20);

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
  final StreamController<Map<String, dynamic>> _waitingForOthersController =
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
  Stream<Map<String, dynamic>> get waitingForOthers => _waitingForOthersController.stream;
  Stream<Map<String, dynamic>> get questionResult => _questionResultController.stream;
  Stream<Map<String, dynamic>> get gameFinished => _gameFinishedController.stream;

  /// Never throws — a failed connect (no token yet, no network, the
  /// endpoint not being up) just leaves the lobby features quietly
  /// inactive instead of crashing the caller, same as this app's other
  /// silent-catch data loads.
  ///
  /// Waits for [WebSocketChannel.ready] before marking the connection
  /// live and installing the message listener — `WebSocketChannel.
  /// connect()` returns immediately, before the handshake finishes, so
  /// reporting "connected" (or accepting `send()` calls) any earlier
  /// risked silently dropping the first message sent right after
  /// `connect()` (e.g. `lobby_create`/`lobby_join` fired the instant a
  /// screen mounts).
  Future<void> connect() {
    if (_channel != null) return Future.value();
    return _connecting ??= _doConnect().whenComplete(() => _connecting = null);
  }

  Future<void> _doConnect() async {
    try {
      final String? token = await _tokenStorage.readAccessToken();
      if (token == null) return;

      final Uri uri = Uri.parse('${AppConfig.wsBaseUrl}/ws/lobby');

      final WebSocketChannel channel = WebSocketChannel.connect(uri);
      await channel.ready;
      // Token endi ulanish manzilida emas (serverning access log'iga to'liq
      // so'rov manzili bilan birga yozilib qolmasligi uchun) - ulanish
      // ochilgach birinchi xabar sifatida yuboriladi.
      channel.sink.add(jsonEncode({'type': 'auth', 'token': token}));

      _channel = channel;
      _lastActivityAt = DateTime.now();
      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: () {
          _channel = null;
          _stopTimers();
          _connectionController.add(false);
        },
        onError: (_) {
          _channel = null;
          _stopTimers();
          _connectionController.add(false);
        },
      );
      _keepAliveTimer = Timer.periodic(_keepAliveInterval, (_) => unawaited(send({'type': 'ping'})));
      _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) => _checkConnectionHealth());
      _connectionController.add(true);
    } catch (_) {
      _channel = null;
      _connectionController.add(false);
    }
  }

  void _stopTimers() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  void _checkConnectionHealth() {
    if (_channel == null) return;
    if (DateTime.now().difference(_lastActivityAt) <= _deadConnectionThreshold) return;
    disconnect();
    unawaited(connect());
  }

  void _handleMessage(dynamic raw) {
    _lastActivityAt = DateTime.now();
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
      case 'lobby_waiting_for_others':
        _waitingForOthersController.add(json);
      case 'lobby_question_result':
        _questionResultController.add(json);
      case 'lobby_game_finished':
        _gameFinishedController.add(json);
    }
  }

  /// Waits for a live connection before writing — without this, a
  /// message sent while [connect] is still in flight (e.g. the caller
  /// navigated to create/join a room right after app launch, before
  /// Home's own `connect()` call had finished) or while a dropped
  /// connection is mid-reconnect would silently vanish into a null
  /// `_channel`.
  Future<void> send(Map<String, dynamic> message) async {
    await connect();
    _channel?.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _stopTimers();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _connectionController.add(false);
  }
}

final Provider<LobbySocketDataSource> lobbySocketDataSourceProvider = Provider<LobbySocketDataSource>(
  (ref) {
    final ds = LobbySocketDataSource(ref.watch(tokenStorageProvider));
    ref.onDispose(() => ds.disconnect());
    return ds;
  },
);
