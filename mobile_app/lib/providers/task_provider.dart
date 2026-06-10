import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_task.dart';
import '../models/annotator/label.dart';
import '../models/annotator/task_item.dart';
import '../models/common/api_error.dart';
import '../repositories/annotator_repository.dart';

enum TaskState { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  final AnnotatorRepository _annotatorRepository;

  TaskState _state = TaskState.initial;
  List<AnnotatorTask> _tasks = [];
  AnnotatorTask? _selectedTask;
  List<TaskItem> _taskItems = [];
  List<Label> _taskLabels = [];
  String? _errorMessage;

  TaskProvider({AnnotatorRepository? annotatorRepository})
      : _annotatorRepository = annotatorRepository ?? AnnotatorRepository();

  // Getters
  TaskState get state => _state;
  List<AnnotatorTask> get tasks => _tasks;
  AnnotatorTask? get selectedTask => _selectedTask;
  List<TaskItem> get taskItems => _taskItems;
  List<Label> get taskLabels => _taskLabels;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TaskState.loading;

  /// Fetch all tasks for the current user
  Future<void> fetchTasks() async {
    try {
      _state = TaskState.loading;
      _errorMessage = null;
      notifyListeners();

      final tasks = await _annotatorRepository.getTasks();
      _tasks = tasks;
      _state = TaskState.loaded;
      _errorMessage = null;

      Logger.info('✅ Fetched ${tasks.length} tasks');
      notifyListeners();
    } on ApiError catch (e) {
      _state = TaskState.error;
      _errorMessage = e.message;
      Logger.error('❌ Failed to fetch tasks: ${e.message}');
      notifyListeners();
    } catch (e) {
      _state = TaskState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error fetching tasks: $e');
      notifyListeners();
    }
  }

  /// Select a task and fetch its details
  Future<void> selectTask(String taskId) async {
    try {
      _state = TaskState.loading;
      _errorMessage = null;
      notifyListeners();

      // Find task from list
      final task = _tasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => throw ApiError(
          message: AppConstants.errorTaskNotFound,
          code: 'TASK_NOT_FOUND',
        ),
      );

      _selectedTask = task;

      // Fetch task items and labels
      await Future.wait([
        _fetchTaskItems(taskId),
        _fetchTaskLabels(taskId),
      ]);

      _state = TaskState.loaded;
      _errorMessage = null;

      Logger.info('✅ Selected task: $taskId');
      notifyListeners();
    } on ApiError catch (e) {
      _state = TaskState.error;
      _errorMessage = e.message;
      Logger.error('❌ Failed to select task: ${e.message}');
      notifyListeners();
    } catch (e) {
      _state = TaskState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error selecting task: $e');
      notifyListeners();
    }
  }

  /// Fetch task items for a specific task
  Future<void> _fetchTaskItems(String taskId) async {
    try {
      final items = await _annotatorRepository.getTaskItems(taskId);
      _taskItems = items;
      Logger.info('✅ Fetched ${items.length} task items');
    } catch (e) {
      Logger.error('❌ Failed to fetch task items: $e');
      rethrow;
    }
  }

  /// Fetch labels for a specific task
  Future<void> _fetchTaskLabels(String taskId) async {
    try {
      final labels = await _annotatorRepository.getTaskLabels(taskId);
      _taskLabels = labels;
      Logger.info('✅ Fetched ${labels.length} labels');
    } catch (e) {
      Logger.error('❌ Failed to fetch labels: $e');
      rethrow;
    }
  }

  /// Accept a task
  Future<bool> acceptTask(String taskId) async {
    try {
      await _annotatorRepository.acceptTask(taskId);

      // Update task status in local list
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final oldTask = _tasks[index];
        _tasks[index] = AnnotatorTask(
          id: oldTask.id,
          projectId: oldTask.projectId,
          dataItemId: oldTask.dataItemId,
          status: AppConstants.taskStatusInProgress,
          assignedAt: oldTask.assignedAt,
          completedAt: oldTask.completedAt,
        );
        notifyListeners();
      }

      Logger.info('✅ Task accepted: $taskId');
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      Logger.error('❌ Failed to accept task: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error accepting task: $e');
      notifyListeners();
      return false;
    }
  }

  /// Start a task
  Future<bool> startTask(String taskId) async {
    try {
      await _annotatorRepository.startTask(taskId);

      // Update task status in local list
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final oldTask = _tasks[index];
        _tasks[index] = AnnotatorTask(
          id: oldTask.id,
          projectId: oldTask.projectId,
          dataItemId: oldTask.dataItemId,
          status: AppConstants.taskStatusInProgress,
          assignedAt: oldTask.assignedAt,
          completedAt: oldTask.completedAt,
        );
        notifyListeners();
      }

      Logger.info('✅ Task started: $taskId');
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      Logger.error('❌ Failed to start task: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected error starting task: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear selected task
  void clearSelectedTask() {
    _selectedTask = null;
    _taskItems = [];
    _taskLabels = [];
    notifyListeners();
  }
}
