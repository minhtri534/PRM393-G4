import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_models.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../models/reviewer/reviewer_models.dart';
import '../repositories/reviewer_repository.dart';

enum ReviewerLoadState { initial, loading, loaded, error }

class ReviewerProvider extends ChangeNotifier {
  final ReviewerRepository _repository;

  ReviewerProvider({ReviewerRepository? repository})
    : _repository = repository ?? ReviewerRepository();

  ReviewerLoadState _projectsState = ReviewerLoadState.initial;
  ReviewerLoadState _listState = ReviewerLoadState.initial;
  ReviewerLoadState _detailState = ReviewerLoadState.initial;
  String? _errorMessage;
  bool _isSubmitting = false;

  List<MyProjectSummaryModel> _projects = [];
  List<ReviewerSubmittedTaskModel> _tasks = [];
  String? _selectedProjectId;

  ReviewerLabeledDataModel? _labeledData;
  GuidelineComparisonModel? _guidelineComparison;
  LabelConsistencyModel? _labelConsistency;
  List<ReviewerErrorTypeModel> _errorTypes = [];
  Uint8List? _taskImageBytes;
  int _imageWidth = 800;
  int _imageHeight = 600;
  List<LabelingBox> _labelingBoxes = [];
  List<AnnotatorLabelModel> _taskLabels = [];

  ReviewerLoadState get projectsState => _projectsState;
  ReviewerLoadState get listState => _listState;
  ReviewerLoadState get detailState => _detailState;
  String? get errorMessage => _errorMessage;
  bool get isProjectsLoading => _projectsState == ReviewerLoadState.loading;
  bool get isListLoading => _listState == ReviewerLoadState.loading;
  bool get isDetailLoading => _detailState == ReviewerLoadState.loading;
  bool get isSubmitting => _isSubmitting;

  List<MyProjectSummaryModel> get projects => _projects;
  List<ReviewerSubmittedTaskModel> get tasks => _tasks;
  String? get selectedProjectId => _selectedProjectId;
  ReviewerLabeledDataModel? get labeledData => _labeledData;
  GuidelineComparisonModel? get guidelineComparison => _guidelineComparison;
  LabelConsistencyModel? get labelConsistency => _labelConsistency;
  List<ReviewerErrorTypeModel> get errorTypes => _errorTypes;
  Uint8List? get taskImageBytes => _taskImageBytes;
  int get imageWidth => _imageWidth;
  int get imageHeight => _imageHeight;
  List<LabelingBox> get labelingBoxes => _labelingBoxes;
  List<AnnotatorLabelModel> get taskLabels => _taskLabels;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    try {
      _projectsState = ReviewerLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _projects = await _repository.getProjects();
      _projectsState = ReviewerLoadState.loaded;
      Logger.info('✅ Fetched ${_projects.length} reviewer projects');
      notifyListeners();
    } on ApiError catch (e) {
      _projectsState = ReviewerLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _projectsState = ReviewerLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<void> fetchSubmittedTasks({String? projectId}) async {
    try {
      _selectedProjectId = projectId;
      _listState = ReviewerLoadState.loading;
      _errorMessage = null;
      notifyListeners();

      _tasks = await _repository.getSubmittedTasks(projectId: projectId);
      _listState = ReviewerLoadState.loaded;
      Logger.info('✅ Fetched ${_tasks.length} submitted tasks for review');
      notifyListeners();
    } on ApiError catch (e) {
      _listState = ReviewerLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _listState = ReviewerLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<void> loadErrorTypes() async {
    try {
      _errorTypes = await _repository.getErrorTypes();
      notifyListeners();
    } catch (_) {
      _errorTypes = [];
    }
  }

  Future<void> loadReviewDetail(String taskId) async {
    try {
      _detailState = ReviewerLoadState.loading;
      _errorMessage = null;
      _labeledData = null;
      _guidelineComparison = null;
      _labelConsistency = null;
      _taskImageBytes = null;
      _labelingBoxes = [];
      _taskLabels = [];
      notifyListeners();

      final results = await Future.wait([
        _repository.getLabeledData(taskId),
        _repository.getGuidelineComparison(taskId),
        _repository.getConsistencyValidation(taskId),
      ]);

      _labeledData = results[0] as ReviewerLabeledDataModel;
      _guidelineComparison = results[1] as GuidelineComparisonModel;
      _labelConsistency = results[2] as LabelConsistencyModel;

      final annotations = _labeledData!.annotations;
      _labelingBoxes = annotations
          .map((a) => a.toLabelingBox())
          .where((b) => b.width > 0 && b.height > 0)
          .toList();

      final labelMap = <String, AnnotatorLabelModel>{};
      for (var i = 0; i < annotations.length; i++) {
        final item = annotations[i];
        labelMap.putIfAbsent(item.labelId, () => item.toLabelModel(i));
      }
      _taskLabels = labelMap.values.toList();

      try {
        final bytes = await _repository.getTaskContent(taskId);
        if (bytes.isNotEmpty) {
          _taskImageBytes = Uint8List.fromList(bytes);
          await _decodeImageSize(_taskImageBytes!);
        }
      } catch (_) {
        _taskImageBytes = null;
      }

      _detailState = ReviewerLoadState.loaded;
      notifyListeners();
    } on ApiError catch (e) {
      _detailState = ReviewerLoadState.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _detailState = ReviewerLoadState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
    }
  }

  Future<bool> approveTask(
    String taskId, {
    int score = 100,
    String? comment,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      final ok = await _repository.approveTask(
        taskId,
        score: score,
        comment: comment,
      );
      _isSubmitting = false;
      notifyListeners();
      return ok;
    } on ApiError catch (e) {
      _isSubmitting = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnTask(
    String taskId, {
    required String feedback,
    int score = 0,
    List<String>? errorTypeIds,
  }) async {
    try {
      _isSubmitting = true;
      _errorMessage = null;
      notifyListeners();

      final ok = await _repository.returnTask(
        taskId,
        feedback: feedback,
        score: score,
        errorTypeIds: errorTypeIds,
      );
      _isSubmitting = false;
      notifyListeners();
      return ok;
    } on ApiError catch (e) {
      _isSubmitting = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  Future<void> _decodeImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;
      frame.image.dispose();
    } catch (_) {
      _imageWidth = 800;
      _imageHeight = 600;
    }
  }
}
