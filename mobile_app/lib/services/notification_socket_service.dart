import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/app_constants.dart';
import '../core/constants/environment.dart';
import '../core/storage/app_storage.dart';
import '../core/utils/logger.dart';
import '../models/notification/notification_model.dart';

typedef NotificationHandler = void Function(NotificationModel notification);

/// Persistent Socket.IO connection for user-scoped `notification:new` events.
class NotificationSocketService {
  final AppStorage _storage;
  io.Socket? _socket;
  NotificationHandler? _onNotification;
  String? _connectedToken;

  NotificationSocketService({AppStorage? storage})
    : _storage = storage ?? AppStorage.instance;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({NotificationHandler? onNotification}) async {
    _onNotification = onNotification;
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      throw StateError('Missing auth token');
    }

    if (_socket != null &&
        _connectedToken != null &&
        _connectedToken != token) {
      await disconnect();
    }

    if (_socket != null && _socket!.connected && _connectedToken == token) {
      return;
    }

    _connectedToken = token;
    _socket?.dispose();

    final url = Environment.socketUrl;
    Logger.info('🔌 Connecting notification socket to $url');

    final connected = Completer<void>();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        Logger.info('✅ Notification socket connected');
        if (!connected.isCompleted) connected.complete();
      })
      ..onDisconnect((_) => Logger.info('ℹ️ Notification socket disconnected'))
      ..onConnectError((error) {
        Logger.error('❌ Notification socket error: $error');
        if (!connected.isCompleted) {
          connected.completeError(error ?? 'connect_error');
        }
      })
      ..on('notification:new', (data) {
        if (data is Map) {
          final notification = NotificationModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          _onNotification?.call(notification);
        }
      });

    _socket!.connect();

    try {
      await connected.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      // Keep socket for reconnection attempts; surface error to caller.
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
  }
}
