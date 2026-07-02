import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/app_constants.dart';
import '../core/constants/environment.dart';
import '../core/utils/logger.dart';
import '../models/chat/chat_models.dart';

typedef ChatMessageHandler = void Function(ChatMessageModel message);

class ChatSocketService {
  final FlutterSecureStorage _secureStorage;
  io.Socket? _socket;
  ChatMessageHandler? _onMessage;
  String? _connectedToken;

  ChatSocketService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect({ChatMessageHandler? onMessage}) async {
    _onMessage = onMessage;
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      throw StateError('Missing auth token');
    }

    if (_socket != null &&
        _connectedToken != null &&
        _connectedToken != token) {
      await disconnect();
    }

    _connectedToken = token;
    _socket?.dispose();

    final url = Environment.socketUrl;
    Logger.info('🔌 Connecting chat socket to $url');

    final connected = Completer<void>();
    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!
      ..onConnect((_) {
        Logger.info('✅ Chat socket connected');
        if (!connected.isCompleted) connected.complete();
      })
      ..onDisconnect((_) => Logger.info('ℹ️ Chat socket disconnected'))
      ..onConnectError((error) {
        Logger.error('❌ Chat socket error: $error');
        if (!connected.isCompleted) {
          connected.completeError(error ?? 'connect_error');
        }
      })
      ..on('message:new', (data) {
        if (data is Map) {
          final message = ChatMessageModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          _onMessage?.call(message);
        }
      });

    _socket!.connect();

    try {
      await connected.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      _socket?.dispose();
      _socket = null;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
  }

  Future<bool> joinProject(String projectId) async {
    final socket = _socket;
    if (socket == null || !socket.connected) return false;

    final completer = Completer<bool>();
    socket.emitWithAck('join:project', {'projectId': projectId}, ack: (data) {
      if (data is Map && data['ok'] == true) {
        if (!completer.isCompleted) completer.complete(true);
      } else {
        if (!completer.isCompleted) completer.complete(false);
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => false,
    );
  }

  void leaveProject(String projectId) {
    _socket?.emit('leave:project', {'projectId': projectId});
  }

  Future<ChatMessageModel?> sendText({
    required String projectId,
    required String content,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) return null;

    final completer = Completer<ChatMessageModel?>();
    socket.emitWithAck(
      'send:message',
      {'projectId': projectId, 'content': content},
      ack: (data) {
        if (data is Map && data['ok'] == true && data['message'] is Map) {
          if (!completer.isCompleted) {
            completer.complete(
              ChatMessageModel.fromJson(
                Map<String, dynamic>.from(data['message'] as Map),
              ),
            );
          }
        } else {
          if (!completer.isCompleted) completer.complete(null);
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => null,
    );
  }

  Future<void> broadcastMessage({
    required String projectId,
    required ChatMessageModel message,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    socket.emit('broadcast:message', {
      'projectId': projectId,
      'message': {
        'id': message.id,
        'projectId': message.projectId,
        'senderUserId': message.senderUserId,
        'senderFullName': message.senderFullName,
        'messageType': message.messageType,
        'content': message.content,
        'attachmentFileName': message.attachmentFileName,
        'attachmentContentType': message.attachmentContentType,
        'attachmentSizeBytes': message.attachmentSizeBytes,
        'attachmentUrl': message.attachmentUrl,
        'createdAt': message.createdAt.toIso8601String(),
      },
    });
  }
}
