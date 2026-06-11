import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_models.dart';
import '../models/common/api_error.dart';
import '../repositories/annotator_repository.dart';

enum AnnotatorLoadState { initial, loading, loaded, error }

class AnnotatorProvider extends ChangeNotifier {
  final AnnotatorRepository _repository;

  AnnotatorProvider({AnnotatorRepository? repository})
      : _repository = repository ?? AnnotatorRepository();

  AnnotatorLoadState _listState = AnnotatorLoadState.initial;
  AnnotatorLoadState _detailState = AnnotatorLoadState.initial;
  String? _errorMessage;

  List<AnnotatorTaskModel> _tasks = [];
  AnnotatorTaskModel? _selectedTask;
  List<AnnotatorTaskItemModel> _taskItems = [];
  List<AnnotatorLabelModel> _taskLabels = [];
  String? _guideline;
  Uint8List? _taskImageBytes;

  AnnotatorLoadState get listState => _listState;
  AnnotatorLoadState get detailState => _detailState;
  String? get errorMessage => _errorMessage;
  bool get isListLoading => _listState == AnnotatorLoadState.loading;
  bool get isDetailLoading => _detailState == AnnotatorLoadState.loading;

  List<AnnotatorTaskModel> get tasks => _tasks;
  AnnotatorTaskModel? get selectedTask => _selectedTask;
  List<AnnotatorTaskItemModel> get taskItems => _taskItems;
  List<AnnotatorLabelModel> get taskLabels => _taskLabels;
  String? get guideline => _guideline;
  Uint8List? get taskImageBytes => _taskImageBytes;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    try {
      _listState = AnnotatorLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _tasks = await _repository.getTasks();
      _listState = AnnotatorLoadState.loaded;

      Logger.info('✅ Fetched ${_tasks.length} annotator tasks');
      notifyListeners();
    } on ApiError catch (e) {
      _listState = AnnotatorLoadState.error;
      _errorMessage = e.message;
      Logger.error('❌ Failed to fetch tasks: ${e.message}');
      notifyListeners();
    } catch (e) {
      _listState = AnnotatorLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error fetching tasks: $e');
      notifyListeners();
    }
  }

  Future<void> loadTaskDetail(String taskId) async {
    try {
      _detailState = AnnotatorLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      if (_tasks.isEmpty) {
        _tasks = await _repository.getTasks();
      }

      final matches = _tasks.where((t) => t.id == taskId);
      if (matches.isEmpty) {
        throw ApiError(
          message: AppConstants.errorTaskNotFound,
          code: 'TASK_NOT_FOUND',
        );
      }

      final task = matches.first;
      _selectedTask = task;
      _taskImageBytes = null;
      _guideline = null;

      final results = await Future.wait([
        _repository.getTaskItems(taskId),
        _repository.getTaskLabels(taskId),
      ]);

      _taskItems = results[0] as List<AnnotatorTaskItemModel>;
      _taskLabels = results[1] as List<AnnotatorLabelModel>;

      try {
        final guidelineModel = await _repository.getTaskGuideline(taskId);
        _guideline = guidelineModel.guideline;
      } catch (e) {
        Logger.error('⚠️ Could not load guideline: $e');
        _guideline = null;
      }

      try {
        final imageBytes = await _repository.getTaskDataItemContent(taskId);
        if (imageBytes.isNotEmpty) {
          _taskImageBytes = Uint8List.fromList(imageBytes);
        }
      } catch (e) {
        Logger.error('⚠️ Could not load task image: $e');
        _taskImageBytes = null;
      }

      _detailState = AnnotatorLoadState.loaded;
      Logger.info('✅ Loaded task detail: $taskId');
      notifyListeners();
    } on ApiError catch (e) {
      _detailState = AnnotatorLoadState.error;
      _errorMessage = e.message;
      Logger.error('❌ Failed to load task detail: ${e.message}');
      notifyListeners();
    } catch (e) {
      _detailState = AnnotatorLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error loading task detail: $e');
      notifyListeners();
    }
  }

  Future<bool> acceptTask(String taskId) async {
    try {
      await _repository.acceptTask(taskId);
      _updateTaskStatus(taskId, AppConstants.taskStatusInProgress);
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

  Future<bool> startTask(String taskId) async {
    try {
      await _repository.startTask(taskId);
      _updateTaskStatus(taskId, AppConstants.taskStatusInProgress);
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

  void _updateTaskStatus(String taskId, String status) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status);
      if (_selectedTask?.id == taskId) {
        _selectedTask = _tasks[index];
      }
      notifyListeners();
    }
  }

  void clearSelectedTask() {
    _selectedTask = null;
    _taskItems = [];
    _taskLabels = [];
    _guideline = null;
    _taskImageBytes = null;
    _detailState = AnnotatorLoadState.initial;
    notifyListeners();
  }
}
