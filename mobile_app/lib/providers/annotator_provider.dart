import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_models.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../repositories/annotator_repository.dart';

enum AnnotatorLoadState { initial, loading, loaded, error }

class AnnotatorProvider extends ChangeNotifier {
  final AnnotatorRepository _repository;

  AnnotatorProvider({AnnotatorRepository? repository})
    : _repository = repository ?? AnnotatorRepository();

  AnnotatorLoadState _projectsState = AnnotatorLoadState.initial;
  AnnotatorLoadState _listState = AnnotatorLoadState.initial;
  AnnotatorLoadState _detailState = AnnotatorLoadState.initial;
  AnnotatorLoadState _labelingState = AnnotatorLoadState.initial;
  String? _errorMessage;
  bool _isSaving = false;

  List<AnnotatorTaskModel> _tasks = [];
  List<MyProjectSummaryModel> _projects = [];
  String? _selectedProjectId;
  AnnotatorTaskModel? _selectedTask;
  List<AnnotatorTaskItemModel> _taskItems = [];
  List<AnnotatorLabelModel> _taskLabels = [];
  List<AnnotatorAnnotationModel> _annotations = [];
  AnnotatorReviewFeedbackModel? _reviewFeedback;
  String? _guideline;
  Uint8List? _taskImageBytes;

  List<LabelingBox> _labelingBoxes = [];
  String? _selectedLabelId;
  int? _selectedBoxIndex;

  AnnotatorLoadState get projectsState => _projectsState;
  AnnotatorLoadState get listState => _listState;
  AnnotatorLoadState get detailState => _detailState;
  AnnotatorLoadState get labelingState => _labelingState;
  String? get errorMessage => _errorMessage;
  bool get isProjectsLoading => _projectsState == AnnotatorLoadState.loading;
  bool get isListLoading => _listState == AnnotatorLoadState.loading;
  bool get isDetailLoading => _detailState == AnnotatorLoadState.loading;
  bool get isLabelingLoading => _labelingState == AnnotatorLoadState.loading;
  bool get isSaving => _isSaving;

  List<AnnotatorTaskModel> get tasks => _tasks;
  List<MyProjectSummaryModel> get projects => _projects;
  String? get selectedProjectId => _selectedProjectId;
  AnnotatorTaskModel? get selectedTask => _selectedTask;
  List<AnnotatorTaskItemModel> get taskItems => _taskItems;
  List<AnnotatorLabelModel> get taskLabels => _taskLabels;
  List<AnnotatorAnnotationModel> get annotations => _annotations;
  AnnotatorReviewFeedbackModel? get reviewFeedback => _reviewFeedback;
  String? get guideline => _guideline;
  Uint8List? get taskImageBytes => _taskImageBytes;
  List<LabelingBox> get labelingBoxes => _labelingBoxes;
  String? get selectedLabelId => _selectedLabelId;
  int? get selectedBoxIndex => _selectedBoxIndex;

  int get annotationCount => _annotations.length;

  double get selectedTaskProgress {
    final task = _selectedTask;
    if (task == null) return 0;
    final count = _annotations.isNotEmpty
        ? _annotations.length
        : _labelingBoxes.length;
    return annotatorTaskProgress(task.status, count);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    try {
      _projectsState = AnnotatorLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _projects = await _repository.getProjects();
      _projectsState = AnnotatorLoadState.loaded;

      Logger.info('✅ Fetched ${_projects.length} annotator projects');
      notifyListeners();
    } on ApiError catch (e) {
      _projectsState = AnnotatorLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _projectsState = AnnotatorLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<void> fetchTasks({String? projectId}) async {
    try {
      _selectedProjectId = projectId;
      _listState = AnnotatorLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _tasks = await _repository.getTasks(projectId: projectId);
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

      await _ensureTaskLoaded(taskId);

      final results = await Future.wait([
        _repository.getTaskItems(taskId),
        _repository.getTaskLabels(taskId),
        _repository.getTaskAnnotations(taskId),
      ]);

      _taskItems = results[0] as List<AnnotatorTaskItemModel>;
      _taskLabels = results[1] as List<AnnotatorLabelModel>;
      _annotations = results[2] as List<AnnotatorAnnotationModel>;
      _reviewFeedback = null;

      try {
        final guidelineModel = await _repository.getTaskGuideline(taskId);
        _guideline = guidelineModel.guideline;
      } catch (e) {
        Logger.error('⚠️ Could not load guideline: $e');
        _guideline = null;
      }

      if (_selectedTask != null &&
          annotatorTaskNeedsReviewFeedback(_selectedTask!.status)) {
        try {
          _reviewFeedback = await _repository.getTaskReviewFeedback(taskId);
        } catch (e) {
          Logger.error('⚠️ Could not load review feedback: $e');
        }
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

  Future<void> loadLabelingSession(String taskId) async {
    try {
      _labelingState = AnnotatorLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      await _ensureTaskLoaded(taskId);

      final results = await Future.wait([
        _repository.getTaskItems(taskId),
        _repository.getTaskLabels(taskId),
        _repository.getTaskAnnotations(taskId),
      ]);

      _taskItems = results[0] as List<AnnotatorTaskItemModel>;
      _taskLabels = results[1] as List<AnnotatorLabelModel>;
      _annotations = results[2] as List<AnnotatorAnnotationModel>;

      if (_taskLabels.isNotEmpty) {
        _selectedLabelId ??= _taskLabels.first.id;
      }

      _labelingBoxes = _annotations
          .map(LabelingBox.fromAnnotation)
          .where((b) => b.width > 0 && b.height > 0)
          .toList();

      try {
        final guidelineModel = await _repository.getTaskGuideline(taskId);
        _guideline = guidelineModel.guideline;
      } catch (_) {
        _guideline = null;
      }

      if (_selectedTask != null &&
          annotatorTaskNeedsReviewFeedback(_selectedTask!.status)) {
        try {
          _reviewFeedback = await _repository.getTaskReviewFeedback(taskId);
        } catch (_) {
          _reviewFeedback = null;
        }
      }

      try {
        final imageBytes = await _repository.getTaskDataItemContent(taskId);
        if (imageBytes.isNotEmpty) {
          _taskImageBytes = Uint8List.fromList(imageBytes);
        }
      } catch (_) {
        _taskImageBytes = null;
      }

      _labelingState = AnnotatorLoadState.loaded;
      notifyListeners();
    } on ApiError catch (e) {
      _labelingState = AnnotatorLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _labelingState = AnnotatorLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<void> _ensureTaskLoaded(String taskId) async {
    if (_tasks.isEmpty) {
      _tasks = await _repository.getTasks(projectId: _selectedProjectId);
    }

    final matches = _tasks.where((t) => t.id == taskId);
    if (matches.isEmpty) {
      throw ApiError(
        message: AppConstants.errorTaskNotFound,
        code: 'TASK_NOT_FOUND',
      );
    }

    _selectedTask = matches.first;
    _taskImageBytes = null;
    _guideline = null;
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

  Future<bool> rejectTask(String taskId, {String? reason}) async {
    try {
      await _repository.rejectTask(taskId, reason: reason);
      _updateTaskStatus(taskId, AppConstants.taskStatusCancelled);
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

  Future<bool> startAndOpenLabeling(String taskId) async {
    final started = await startTask(taskId);
    return started;
  }

  void selectLabel(String labelId) {
    _selectedLabelId = labelId;
    notifyListeners();
  }

  void selectBox(int? index) {
    _selectedBoxIndex = index;
    notifyListeners();
  }

  void addLabelingBox(LabelingBox box) {
    _labelingBoxes = [..._labelingBoxes, box];
    _selectedBoxIndex = _labelingBoxes.length - 1;
    notifyListeners();
  }

  void removeSelectedBox() {
    final index = _selectedBoxIndex;
    if (index == null || index < 0 || index >= _labelingBoxes.length) return;
    _labelingBoxes = [
      ..._labelingBoxes.sublist(0, index),
      ..._labelingBoxes.sublist(index + 1),
    ];
    _selectedBoxIndex = null;
    notifyListeners();
  }

  Future<bool> saveDraft(String taskId) async {
    if (_labelingBoxes.isEmpty) {
      _errorMessage = 'Draw at least one bounding box before saving.';
      notifyListeners();
      return false;
    }

    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.saveAnnotationDraft(taskId, _labelingBoxes);
      _annotations = await _repository.getTaskAnnotations(taskId);
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _isSaving = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSaving = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitLabeling(String taskId) async {
    if (_labelingBoxes.isEmpty) {
      _errorMessage = 'Label at least one object before submitting.';
      notifyListeners();
      return false;
    }

    try {
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.submitAnnotations(taskId, _labelingBoxes);
      _updateTaskStatus(taskId, AppConstants.taskStatusSubmitted);
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _isSaving = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSaving = false;
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
    _annotations = [];
    _reviewFeedback = null;
    _guideline = null;
    _taskImageBytes = null;
    _labelingBoxes = [];
    _selectedLabelId = null;
    _selectedBoxIndex = null;
    _detailState = AnnotatorLoadState.initial;
    _labelingState = AnnotatorLoadState.initial;
    notifyListeners();
  }
}
