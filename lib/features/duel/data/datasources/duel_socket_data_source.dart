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
  Future<void>? _connecting;
  Timer? _keepAliveTimer;
  Timer? _healthCheckTimer;
  DateTime _lastActivityAt = DateTime.now();

  /// How often to send a no-op message to keep the connection alive.
  /// Render's proxy (and similar cloud reverse proxies) silently closes
  /// WebSocket connections that sit idle for a while, without either
  /// side seeing a clean close frame — a real cause of "invite never
  /// arrived" reports where the recipient's socket looked connected but
  /// had actually gone dead. Any traffic resets that idle timer, so this
  /// doesn't need to be a real ping/pong handshake.
  static const Duration _keepAliveInterval = Duration(seconds: 25);

  /// A connection can go "half-open" — this end still thinks it's
  /// connected (no `onDone`/`onError` ever fired) while the other side
  /// (or a proxy in between) has actually dropped it, so our own pings
  /// go nowhere and nothing ever arrives back either. Since a real ping
  /// goes out every [_keepAliveInterval], seeing NO traffic at all (not
  /// even the server's `pong`) for much longer than that means the
  /// socket is dead in practice even though it doesn't look it — worth
  /// forcing a fresh reconnect for, since that's exactly what causes a
  /// duel invite (or any other live event) to silently never arrive.
  static const Duration _deadConnectionThreshold = Duration(seconds: 70);

  static const Duration _healthCheckInterval = Duration(seconds: 20);

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
  final StreamController<Map<String, dynamic>> _opponentProgressController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelQuestionResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _waitingForOpponentController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelFinishedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _duelCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _errorController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<Map<String, dynamic>> get inviteReceived => _inviteReceivedController.stream;
  Stream<Map<String, dynamic>> get inviteAck => _inviteAckController.stream;
  Stream<Map<String, dynamic>> get inviteAccepted => _inviteAcceptedController.stream;
  Stream<Map<String, dynamic>> get inviteDeclined => _inviteDeclinedController.stream;
  Stream<Map<String, dynamic>> get inviteExpired => _inviteExpiredController.stream;
  Stream<Map<String, dynamic>> get duelStarted => _duelStartedController.stream;
  Stream<Map<String, dynamic>> get duelQuestion => _duelQuestionController.stream;
  Stream<Map<String, dynamic>> get opponentProgress => _opponentProgressController.stream;
  Stream<Map<String, dynamic>> get duelQuestionResult => _duelQuestionResultController.stream;
  Stream<Map<String, dynamic>> get waitingForOpponent => _waitingForOpponentController.stream;
  Stream<Map<String, dynamic>> get duelFinished => _duelFinishedController.stream;
  Stream<Map<String, dynamic>> get duelCancelled => _duelCancelledController.stream;

  /// `{"type": "error", "detail": ..., "client_invite_id": ...?}` — sent
  /// when the server rejects an outgoing `duel_invite` (e.g. the other
  /// person is no longer a friend, or the category was deactivated).
  /// Without this, a rejected invite got no `duel_invite_ack` and no
  /// other signal at all, so the sender just sat on Duel Waiting until
  /// its unrelated 20s "couldn't connect" timeout fired — the wrong
  /// explanation for what actually happened.
  Stream<Map<String, dynamic>> get error => _errorController.stream;

  bool get isConnected => _channel != null;

  /// Never throws — a failed connect (no token yet, no network, the
  /// endpoint not being up) just leaves the duel features quietly
  /// inactive instead of crashing the caller, same as this app's other
  /// silent-catch data loads.
  ///
  /// Waits for [WebSocketChannel.ready] before marking the connection
  /// live and installing the message listener — `WebSocketChannel.
  /// connect()` returns immediately, before the handshake finishes, so
  /// reporting "connected" (or accepting `send()` calls) any earlier
  /// risked silently dropping the first message sent right after
  /// `connect()` (e.g. an invite fired the instant Home mounts).
  Future<void> connect() {
    if (_channel != null) return Future.value();
    return _connecting ??= _doConnect().whenComplete(() => _connecting = null);
  }

  Future<void> _doConnect() async {
    try {
      final String? token = await _tokenStorage.readAccessToken();
      if (token == null) return;

      final Uri uri = Uri.parse('${AppConfig.wsBaseUrl}/ws/duel');

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
      case 'duel_opponent_progress':
        _opponentProgressController.add(json);
      case 'duel_question_result':
        _duelQuestionResultController.add(json);
      case 'duel_waiting_for_opponent':
        _waitingForOpponentController.add(json);
      case 'duel_finished':
        _duelFinishedController.add(json);
      case 'duel_cancelled':
        _duelCancelledController.add(json);
      case 'error':
        _errorController.add(json);
    }
  }

  /// Waits for a live connection before writing — without this, a
  /// message sent while [connect] is still in flight (e.g. the caller
  /// navigated to send an invite right after app launch, before Home's
  /// own `connect()` call had finished) or while a dropped connection is
  /// mid-reconnect would silently vanish into a null `_channel`.
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

final Provider<DuelSocketDataSource> duelSocketDataSourceProvider = Provider<DuelSocketDataSource>(
  (ref) => DuelSocketDataSource(ref.watch(tokenStorageProvider)),
);
