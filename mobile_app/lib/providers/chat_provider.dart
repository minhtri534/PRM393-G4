import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../repositories/chat_repository.dart';
import '../services/chat_socket_service.dart';

enum ChatLoadState { initial, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;
  final ChatSocketService _socketService;

  ChatProvider({
    ChatRepository? repository,
    ChatSocketService? socketService,
  })  : _repository = repository ?? ChatRepository(),
        _socketService = socketService ?? ChatSocketService();

  ChatLoadState _projectsState = ChatLoadState.initial;
  ChatLoadState _roomState = ChatLoadState.initial;
  String? _errorMessage;
  bool _isSending = false;

  List<MyProjectSummaryModel> _projects = [];
  List<ChatMessageModel> _messages = [];
  String? _activeProjectId;
  String? _activeProjectName;
  bool _realtimeEnabled = false;

  ChatLoadState get projectsState => _projectsState;
  ChatLoadState get roomState => _roomState;
  String? get errorMessage => _errorMessage;
  bool get isSending => _isSending;
  bool get realtimeEnabled => _realtimeEnabled;
  List<MyProjectSummaryModel> get projects => _projects;
  List<ChatMessageModel> get messages => _messages;
  String? get activeProjectId => _activeProjectId;
  String? get activeProjectName => _activeProjectName;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    try {
      _projectsState = ChatLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _projects = await _repository.getProjects();
      _projectsState = ChatLoadState.loaded;
      notifyListeners();
    } on ApiError catch (e) {
      _projectsState = ChatLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _projectsState = ChatLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ fetchProjects failed: $e');
      notifyListeners();
    }
  }

  Future<void> openRoom({
    required String projectId,
    required String projectName,
  }) async {
    try {
      _activeProjectId = projectId;
      _activeProjectName = projectName;
      _roomState = ChatLoadState.loading;
      _errorMessage = null;
      _messages = [];
      _realtimeEnabled = false;
      notifyListeners();

      try {
        await _socketService.connect(onMessage: _handleIncomingMessage);
        final joined = await _socketService.joinProject(projectId);
        _realtimeEnabled = joined;
        if (!joined) {
          _errorMessage =
              'Realtime unavailable — you can still send messages (no live updates).';
        }
      } catch (e) {
        _realtimeEnabled = false;
        _errorMessage =
            'Realtime server is offline. Start realtime-server on port 5001. Messages still work via API.';
        Logger.error('❌ Chat socket connect failed: $e');
      }

      _messages = await _repository.getMessages(projectId);
      _roomState = ChatLoadState.loaded;
      notifyListeners();
    } on ApiError catch (e) {
      _roomState = ChatLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _roomState = ChatLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  void _handleIncomingMessage(ChatMessageModel message) {
    if (message.projectId != _activeProjectId) return;
    if (_messages.any((m) => m.id == message.id)) return;
    _messages = [..._messages, message];
    notifyListeners();
  }

  Future<bool> sendText(String content) async {
    final projectId = _activeProjectId;
    if (projectId == null) return false;
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    try {
      _isSending = true;
      _errorMessage = null;
      notifyListeners();

      // Always persist via REST so the sender matches the current login token.
      final sent = await _repository.sendTextMessage(
        projectId: projectId,
        content: trimmed,
      );

      if (!_messages.any((m) => m.id == sent.id)) {
        _messages = [..._messages, sent];
      }

      if (_realtimeEnabled && _socketService.isConnected) {
        await _socketService.broadcastMessage(
          projectId: projectId,
          message: sent,
        );
      }

      _isSending = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _isSending = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSending = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  Future<bool> pickAndSendAttachment() async {
    final projectId = _activeProjectId;
    if (projectId == null) return false;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return false;
    final file = result.files.first;
    final path = file.path;
    if (path == null || path.isEmpty) return false;

    try {
      _isSending = true;
      _errorMessage = null;
      notifyListeners();

      final message = await _repository.sendAttachment(
        projectId: projectId,
        filePath: path,
        fileName: file.name,
      );

      if (!_messages.any((m) => m.id == message.id)) {
        _messages = [..._messages, message];
      }

      if (_realtimeEnabled && _socketService.isConnected) {
        await _socketService.broadcastMessage(
          projectId: projectId,
          message: message,
        );
      }

      _isSending = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _isSending = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSending = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  Future<void> resetSession() async {
    await closeRoom();
    _projects = [];
    _projectsState = ChatLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> closeRoom() async {
    final projectId = _activeProjectId;
    if (projectId != null) {
      _socketService.leaveProject(projectId);
    }
    await _socketService.disconnect();
    _activeProjectId = null;
    _activeProjectName = null;
    _messages = [];
    _realtimeEnabled = false;
    _roomState = ChatLoadState.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
