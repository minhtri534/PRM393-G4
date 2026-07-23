import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/common/api_error.dart';
import '../models/notification/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_socket_service.dart';

enum NotificationLoadState { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  final NotificationSocketService _socketService;

  NotificationProvider({
    NotificationRepository? repository,
    NotificationSocketService? socketService,
  }) : _repository = repository ?? NotificationRepository(),
       _socketService = socketService ?? NotificationSocketService();

  NotificationLoadState _state = NotificationLoadState.initial;
  String? _errorMessage;
  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _realtimeEnabled = false;
  bool _started = false;

  NotificationLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get realtimeEnabled => _realtimeEnabled;
  bool get hasUnread => _unreadCount > 0;

  Future<void> start() async {
    if (_started) {
      await refresh();
      return;
    }
    _started = true;
    await refresh();
    await _connectSocket();
  }

  Future<void> stop() async {
    _started = false;
    await _socketService.disconnect();
    _items = [];
    _unreadCount = 0;
    _realtimeEnabled = false;
    _state = NotificationLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    try {
      _state = NotificationLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _repository.getNotifications(),
        _repository.getUnreadCount(),
      ]);

      _items = results[0] as List<NotificationModel>;
      _unreadCount = results[1] as int;
      _state = NotificationLoadState.loaded;
      notifyListeners();
    } on ApiError catch (e) {
      _state = NotificationLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _state = NotificationLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ notification refresh failed: $e');
      notifyListeners();
    }
  }

  Future<void> _connectSocket() async {
    try {
      await _socketService.connect(onNotification: _handleIncoming);
      _realtimeEnabled = _socketService.isConnected;
      notifyListeners();
    } catch (e) {
      _realtimeEnabled = false;
      Logger.error('❌ notification socket failed: $e');
      notifyListeners();
    }
  }

  void _handleIncoming(NotificationModel notification) {
    if (_items.any((n) => n.id == notification.id)) return;
    _items = [notification, ..._items];
    if (!notification.isRead) {
      _unreadCount += 1;
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((n) => n.id == id);
    if (index < 0) return;
    if (_items[index].isRead) return;

    _items = [
      for (var i = 0; i < _items.length; i++)
        if (i == index) _items[i].copyWith(isRead: true) else _items[i],
    ];
    _unreadCount = (_unreadCount - 1).clamp(0, 999999);
    notifyListeners();

    try {
      await _repository.markRead([id]);
    } catch (e) {
      Logger.error('❌ markRead failed: $e');
    }
  }

  Future<void> markAllRead() async {
    if (_unreadCount == 0) return;
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllRead();
    } catch (e) {
      Logger.error('❌ markAllRead failed: $e');
    }
  }

  Future<bool> sendProjectNotification({
    required String projectId,
    required String title,
    String? body,
  }) async {
    try {
      await _repository.sendProjectNotification(
        projectId: projectId,
        title: title,
        body: body,
      );
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
