import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/common/api_error.dart';
import '../models/manager/activity_log_model.dart';
import '../models/manager/annotator_performance_model.dart';
import '../models/manager/dataset_model.dart';
import '../models/manager/export_model.dart';
import '../models/manager/export_validation_model.dart';
import '../models/manager/label_model.dart';
import '../models/manager/manager_task_model.dart';
import '../models/manager/project_model.dart';
import '../models/manager/quality_report_model.dart';
import '../models/manager/role_model.dart';
import '../models/manager/task_history_model.dart';
import '../models/manager/task_progress_model.dart';
import '../models/manager/user_account_status.dart';
import '../models/manager/user_model.dart';
import '../models/manager/user_project_role_model.dart';
import '../models/manager/user_summary_model.dart';
import '../repositories/manager_repository.dart';

enum ManagerLoadState { initial, loading, loaded, error }

class ManagerProvider extends ChangeNotifier {
  final ManagerRepository _repository;

  ManagerProvider({ManagerRepository? repository})
    : _repository = repository ?? ManagerRepository();

  ManagerLoadState _state = ManagerLoadState.initial;
  String? _errorMessage;

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  List<DatasetModel> _datasets = [];
  List<DatasetModel> _allDatasets = [];
  DatasetModel? _selectedDataset;
  List<LabelModel> _labels = [];
  List<UserProjectRoleModel> _projectRoles = [];
  List<ManagerTaskModel> _projectTasks = [];
  TaskProgressModel? _taskProgress;
  QualityReportModel? _qualityReport;
  List<AnnotatorPerformanceModel> _annotatorPerformance = [];
  List<ExportModel> _exports = [];
  ExportValidationModel? _exportValidation;
  List<ActivityLogModel> _activityLogs = [];
  List<UserSummaryModel> _userSearchResults = [];
  List<UserModel> _users = [];
  List<RoleModel> _roles = [];
  UserModel? _selectedUser;

  ManagerLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ManagerLoadState.loading;

  List<ProjectModel> get projects => _projects;
  ProjectModel? get selectedProject => _selectedProject;
  List<DatasetModel> get datasets => _datasets;
  List<DatasetModel> get allDatasets => _allDatasets;
  DatasetModel? get selectedDataset => _selectedDataset;
  List<LabelModel> get labels => _labels;
  List<UserProjectRoleModel> get projectRoles => _projectRoles;
  List<ManagerTaskModel> get projectTasks => _projectTasks;
  TaskProgressModel? get taskProgress => _taskProgress;
  QualityReportModel? get qualityReport => _qualityReport;
  List<AnnotatorPerformanceModel> get annotatorPerformance =>
      _annotatorPerformance;
  List<ExportModel> get exports => _exports;
  ExportValidationModel? get exportValidation => _exportValidation;
  List<ActivityLogModel> get activityLogs => _activityLogs;
  List<UserSummaryModel> get userSearchResults => _userSearchResults;
  List<UserModel> get users => _users;
  List<RoleModel> get roles => _roles;
  UserModel? get selectedUser => _selectedUser;

  List<RoleModel> get assignableRoles =>
      _roles.where((role) => role.isAssignableByManager).toList();

  List<UserProjectRoleModel> get annotators => _projectRoles
      .where((r) => r.roleName.toLowerCase() == 'annotator')
      .toList();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    try {
      _errorMessage = null;
      await action();
      _state = ManagerLoadState.loaded;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _state = ManagerLoadState.error;
      Logger.error('❌ Manager action failed: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = AppConstants.errorGeneric;
      _state = ManagerLoadState.error;
      Logger.error('❌ Manager unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchProjects() async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      _projects = await _repository.getProjects();
    });
  }

  Future<void> fetchAllDatasets() async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      if (_projects.isEmpty) {
        _projects = await _repository.getProjects();
      }
      final results = <DatasetModel>[];
      for (final project in _projects) {
        final projectDatasets = await _repository.getDatasets(project.id);
        results.addAll(projectDatasets);
      }
      _allDatasets = results;
    });
  }

  Future<bool> createProject({required String name, String? guideline}) async {
    return _runAction(() async {
      final project = await _repository.createProject(
        name: name,
        guideline: guideline,
      );
      _projects = [project, ..._projects];
    });
  }

  Future<bool> archiveProject(String projectId) async {
    return _runAction(() async {
      final updated = await _repository.archiveProject(projectId);
      _projects = _projects
          .map((p) => p.id == projectId ? updated : p)
          .toList();
      if (_selectedProject?.id == projectId) {
        _selectedProject = updated;
      }
    });
  }

  Future<bool> deleteProject(String projectId) async {
    return _runAction(() async {
      await _repository.deleteProject(projectId);
      _projects = _projects.where((p) => p.id != projectId).toList();
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
    });
  }

  Future<void> loadProjectDetail(String projectId) async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      _selectedProject = await _repository.getProjectById(projectId);
      await _loadProjectRelatedData(projectId);
    });
  }

  Future<void> _loadProjectRelatedData(String projectId) async {
    final results = await Future.wait([
      _repository.getDatasets(projectId),
      _repository.getLabels(projectId),
      _repository.getProjectRoles(projectId),
    ]);
    _datasets = results[0] as List<DatasetModel>;
    _labels = results[1] as List<LabelModel>;
    _projectRoles = results[2] as List<UserProjectRoleModel>;
  }

  Future<bool> updateGuideline(String projectId, String guideline) async {
    return _runAction(() async {
      _selectedProject = await _repository.updateGuideline(
        projectId,
        guideline,
      );
      _projects = _projects
          .map((p) => p.id == projectId ? _selectedProject! : p)
          .toList();
    });
  }

  Future<bool> assignProjectRole({
    required String projectId,
    required String userId,
    required String roleId,
  }) async {
    return _runAction(() async {
      final role = await _repository.assignProjectRole(
        projectId: projectId,
        userId: userId,
        roleId: roleId,
      );
      _projectRoles = [..._projectRoles, role];
    });
  }

  Future<void> searchUsers(String query, {String? role}) async {
    if (query.trim().length < 2) {
      _userSearchResults = [];
      notifyListeners();
      return;
    }
    await _runAction(() async {
      _userSearchResults = await _repository.searchUsers(
        query: query,
        role: role,
      );
    });
  }

  Future<void> fetchUsers() async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      _users = await _repository.getUsers();
    });
  }

  Future<void> fetchRoles() async {
    await _runAction(() async {
      _roles = await _repository.getRoles();
    });
  }

  Future<void> loadUserDetail(String userId) async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      _selectedUser = await _repository.getUserById(userId);
    });
  }

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String password,
    required String roleId,
    int status = UserAccountStatus.active,
    String? phoneNumber,
  }) async {
    return _runAction(() async {
      final user = await _repository.createUser(
        fullName: fullName,
        email: email,
        password: password,
        roleId: roleId,
        status: status,
        phoneNumber: phoneNumber,
      );
      _users = [user, ..._users];
    });
  }

  Future<bool> updateUser({
    required String userId,
    required String fullName,
    required String email,
    required String roleId,
    required int status,
    String? password,
    String? phoneNumber,
  }) async {
    return _runAction(() async {
      final user = await _repository.updateUser(
        userId: userId,
        fullName: fullName,
        email: email,
        roleId: roleId,
        status: status,
        password: password,
        phoneNumber: phoneNumber,
      );
      _selectedUser = user;
      _users = _users.map((u) => u.id == userId ? user : u).toList();
    });
  }

  Future<bool> deleteUser(String userId) async {
    return _runAction(() async {
      await _repository.deleteUser(userId);
      _users = _users.where((u) => u.id != userId).toList();
      if (_selectedUser?.id == userId) {
        _selectedUser = null;
      }
    });
  }

  List<UserModel> filterUsers(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return _users;
    return _users
        .where(
          (user) =>
              user.fullName.toLowerCase().contains(normalized) ||
              user.email.toLowerCase().contains(normalized) ||
              (user.roleName ?? '').toLowerCase().contains(normalized),
        )
        .toList();
  }

  Future<bool> createDataset({
    required String projectId,
    required String name,
  }) async {
    return _runAction(() async {
      final dataset = await _repository.createDataset(
        projectId: projectId,
        name: name,
      );
      _datasets = [dataset, ..._datasets];
      _allDatasets = [dataset, ..._allDatasets];
    });
  }

  Future<void> loadDatasetDetail(String datasetId) async {
    _state = ManagerLoadState.loading;
    notifyListeners();
    await _runAction(() async {
      _selectedDataset = await _repository.getDatasetById(datasetId);
    });
  }

  Future<bool> updateDatasetName(String datasetId, String name) async {
    return _runAction(() async {
      _selectedDataset = await _repository.updateDataset(datasetId, name);
      _datasets = _datasets
          .map((d) => d.id == datasetId ? _selectedDataset! : d)
          .toList();
      _allDatasets = _allDatasets
          .map((d) => d.id == datasetId ? _selectedDataset! : d)
          .toList();
    });
  }

  Future<bool> deleteDataset(String datasetId) async {
    return _runAction(() async {
      await _repository.deleteDataset(datasetId);
      _datasets = _datasets.where((d) => d.id != datasetId).toList();
      _allDatasets = _allDatasets.where((d) => d.id != datasetId).toList();
      _selectedDataset = null;
    });
  }

  Future<bool> uploadDatasetFiles({
    required String datasetId,
    required List<MultipartFile> files,
  }) async {
    return _runAction(() async {
      await _repository.uploadDatasetFiles(datasetId: datasetId, files: files);
      _selectedDataset = await _repository.getDatasetById(datasetId);
    });
  }

  Future<bool> createLabel({
    required String projectId,
    required String name,
  }) async {
    return _runAction(() async {
      final label = await _repository.createLabel(
        projectId: projectId,
        name: name,
        yoloClassId: _nextLabelClassId(_labels),
      );
      _labels = [label, ..._labels];
    });
  }

  int _nextLabelClassId(List<LabelModel> labels) {
    if (labels.isEmpty) return 0;
    var maxId = labels.first.yoloClassId;
    for (final label in labels) {
      if (label.yoloClassId > maxId) maxId = label.yoloClassId;
    }
    return maxId + 1;
  }

  Future<void> loadProjectTasks(String projectId) async {
    await _runAction(() async {
      final results = await Future.wait([
        _repository.getProjectTasks(projectId),
        _repository.getTaskProgress(projectId),
      ]);
      _projectTasks = results[0] as List<ManagerTaskModel>;
      _taskProgress = results[1] as TaskProgressModel;
    });
  }

  Future<bool> bulkCreateTasks({
    required String projectId,
    required String datasetId,
    required String annotatorId,
  }) async {
    return _runAction(() async {
      await _repository.bulkCreateTasksByDataset(
        projectId: projectId,
        datasetId: datasetId,
        annotatorId: annotatorId,
      );
      await loadProjectTasks(projectId);
    });
  }

  Future<bool> assignTask(String taskId, String annotatorId) async {
    return _runAction(() async {
      final updated = await _repository.assignTask(taskId, annotatorId);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<bool> pauseTask(String taskId) async {
    return _runAction(() async {
      final updated = await _repository.pauseTask(taskId);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<bool> cancelTask(String taskId) async {
    return _runAction(() async {
      final updated = await _repository.cancelTask(taskId);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<void> loadMonitoring(String projectId) async {
    await _runAction(() async {
      final results = await Future.wait([
        _repository.getQualityReport(projectId),
        _repository.getAnnotatorPerformance(projectId),
      ]);
      _qualityReport = results[0] as QualityReportModel;
      _annotatorPerformance = results[1] as List<AnnotatorPerformanceModel>;
    });
  }

  Future<void> loadExports(String projectId) async {
    await _runAction(() async {
      final results = await Future.wait([
        _repository.getProjectExports(projectId),
        _repository.validateApprovedData(projectId),
        _repository.getActivityLogs(projectId: projectId),
      ]);
      _exports = results[0] as List<ExportModel>;
      _exportValidation = results[1] as ExportValidationModel;
      _activityLogs = results[2] as List<ActivityLogModel>;
    });
  }

  Future<bool> createExport({
    required String projectId,
    String format = 'JSON',
    String labelFormat = 'JSON',
  }) async {
    return _runAction(() async {
      final export = await _repository.createExport(
        projectId: projectId,
        format: format,
        exportPath: 'exports/$projectId/export.json',
        labelFormat: labelFormat,
      );
      _exports = [export, ..._exports];
    });
  }

  Future<List<int>?> downloadExport(String exportId) async {
    try {
      return await _repository.downloadExport(exportId);
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateProject({
    required String projectId,
    required String name,
    String? guideline,
    required int status,
  }) async {
    return _runAction(() async {
      _selectedProject = await _repository.updateProject(
        projectId,
        name: name,
        guideline: guideline,
        status: status,
      );
      _projects = _projects
          .map((p) => p.id == projectId ? _selectedProject! : p)
          .toList();
    });
  }

  Future<bool> changeProjectStatus({
    required String projectId,
    required String name,
    String? guideline,
    required int status,
  }) async {
    return _runAction(() async {
      _selectedProject = await _repository.changeProjectStatus(
        projectId,
        name: name,
        guideline: guideline,
        status: status,
      );
      _projects = _projects
          .map((p) => p.id == projectId ? _selectedProject! : p)
          .toList();
    });
  }

  Future<bool> updateLabel(String labelId, {required String name}) async {
    LabelModel? existing;
    for (final label in _labels) {
      if (label.id == labelId) {
        existing = label;
        break;
      }
    }
    if (existing == null) return false;
    final labelClassId = existing.yoloClassId;

    return _runAction(() async {
      final updated = await _repository.updateLabel(
        labelId,
        name: name,
        yoloClassId: labelClassId,
      );
      _labels = _labels.map((l) => l.id == labelId ? updated : l).toList();
    });
  }

  Future<bool> deleteLabel(String labelId) async {
    return _runAction(() async {
      await _repository.deleteLabel(labelId);
      _labels = _labels.where((l) => l.id != labelId).toList();
    });
  }

  Future<bool> createTask({
    required String projectId,
    required String dataItemId,
    required String annotatorId,
  }) async {
    return _runAction(() async {
      final task = await _repository.createTask(
        projectId: projectId,
        dataItemId: dataItemId,
        annotatorId: annotatorId,
      );
      _projectTasks = [task, ..._projectTasks];
    });
  }

  Future<bool> reassignTask(String taskId, String annotatorId) async {
    return _runAction(() async {
      final updated = await _repository.reassignTask(taskId, annotatorId);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<bool> resumeTask(String taskId) async {
    return _runAction(() async {
      final updated = await _repository.resumeTask(taskId);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<bool> requestRelabeling(String taskId, String reason) async {
    return _runAction(() async {
      final updated = await _repository.requestRelabeling(taskId, reason);
      _projectTasks = _projectTasks
          .map((t) => t.id == taskId ? updated : t)
          .toList();
    });
  }

  Future<List<TaskHistoryModel>> getTaskHistory(String taskId) async {
    try {
      return await _repository.getTaskHistory(taskId);
    } on ApiError catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return [];
    }
  }
}
