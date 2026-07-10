import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/manager_endpoints.dart';
import '../core/utils/logger.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import '../models/manager/manager_models.dart';
import 'dio_client.dart';

class ManagerRepository {
  final DioClient _dioClient;

  ManagerRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  Future<T> _unwrap<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic data) decoder,
  ) async {
    final response = await request();
    final serviceResponse = ServiceResponse<T>.fromJson(
      response.data as Map<String, dynamic>,
      decoder,
    );
    if (!serviceResponse.isSuccess) {
      throw ApiError(
        message: serviceResponse.message.isNotEmpty
            ? serviceResponse.message
            : AppConstants.errorGeneric,
        code: 'MANAGER_API_FAILED',
      );
    }
    if (serviceResponse.data == null) {
      throw ApiError(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }
    return serviceResponse.data as T;
  }

  Future<List<T>> _unwrapList<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return _unwrap<List<T>>(
      request,
      (data) => (data as List<dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // ================= PROJECTS =================

  Future<List<ProjectModel>> getProjects() => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.projects),
    ProjectModel.fromJson,
  );

  Future<ProjectModel> getProjectById(String projectId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.project(projectId)),
    (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ProjectModel> createProject({
    required String name,
    String? guideline,
    int status = 0,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.projects,
      data: {'name': name, 'guideline': ?guideline, 'status': status},
    ),
    (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ProjectModel> updateProject(
    String projectId, {
    required String name,
    String? guideline,
    required int status,
  }) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.project(projectId),
      data: {'name': name, 'guideline': ?guideline, 'status': status},
    ),
    (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteProject(String projectId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.project(projectId)),
    (data) => data as bool,
  );

  Future<ProjectModel> archiveProject(String projectId) => _unwrap(
    () => _dioClient.post(ManagerEndpoints.projectArchive(projectId)),
    (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ProjectModel> changeProjectStatus(
    String projectId, {
    required String name,
    String? guideline,
    required int status,
  }) => _unwrap(
    () => _dioClient.patch(
      ManagerEndpoints.projectStatus(projectId),
      data: {'name': name, 'guideline': ?guideline, 'status': status},
    ),
    (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ProjectModel> updateGuideline(String projectId, String? guideline) =>
      _unwrap(
        () => _dioClient.patch(
          ManagerEndpoints.projectGuideline(projectId),
          data: {'guideline': guideline},
        ),
        (data) => ProjectModel.fromJson(data as Map<String, dynamic>),
      );

  // ================= PROJECT ROLES =================

  Future<List<UserProjectRoleModel>> getProjectRoles(String projectId) =>
      _unwrapList(
        () => _dioClient.get(ManagerEndpoints.projectRoles(projectId)),
        UserProjectRoleModel.fromJson,
      );

  Future<UserProjectRoleModel> assignProjectRole({
    required String projectId,
    required String userId,
    required String roleId,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.projectRolesAssign,
      data: {'projectId': projectId, 'userId': userId, 'roleId': roleId},
    ),
    (data) => UserProjectRoleModel.fromJson(data as Map<String, dynamic>),
  );

  // ================= DATASETS =================

  Future<List<DatasetModel>> getDatasets(String projectId) => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.projectDatasets(projectId)),
    DatasetModel.fromJson,
  );

  Future<DatasetModel> getDatasetById(String datasetId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.dataset(datasetId)),
    (data) => DatasetModel.fromJson(data as Map<String, dynamic>),
  );

  Future<DatasetModel> createDataset({
    required String projectId,
    required String name,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.datasets,
      data: {'projectId': projectId, 'name': name},
    ),
    (data) => DatasetModel.fromJson(data as Map<String, dynamic>),
  );

  Future<DatasetModel> updateDataset(String datasetId, String name) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.dataset(datasetId),
      data: {'name': name},
    ),
    (data) => DatasetModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteDataset(String datasetId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.dataset(datasetId)),
    (data) => data as bool,
  );

  Future<UploadDatasetItemsResult> uploadDatasetItems({
    required String datasetId,
    required List<Map<String, dynamic>> items,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.datasetsUpload,
      data: {'datasetId': datasetId, 'items': items},
    ),
    (data) => UploadDatasetItemsResult.fromJson(data as Map<String, dynamic>),
  );

  Future<UploadDatasetItemsResult> uploadDatasetFiles({
    required String datasetId,
    required List<MultipartFile> files,
  }) async {
    final formData = FormData.fromMap({'datasetId': datasetId, 'files': files});
    return _unwrap(
      () =>
          _dioClient.post(ManagerEndpoints.datasetsUploadFiles, data: formData),
      (data) => UploadDatasetItemsResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<UploadDatasetItemsResult> importDatasetExternal({
    required String datasetId,
    required String sourceName,
    required List<Map<String, dynamic>> items,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.datasetsImportExternal,
      data: {'datasetId': datasetId, 'sourceName': sourceName, 'items': items},
    ),
    (data) => UploadDatasetItemsResult.fromJson(data as Map<String, dynamic>),
  );

  // ================= DATASET VERSIONS =================

  Future<DatasetVersionModel> createDatasetVersion({
    required String datasetId,
    required String versionName,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.datasetVersionsCreate,
      data: {'datasetId': datasetId, 'versionName': versionName},
    ),
    (data) => DatasetVersionModel.fromJson(data as Map<String, dynamic>),
  );

  Future<List<DatasetVersionModel>> getDatasetVersions(String datasetId) =>
      _unwrapList(
        () => _dioClient.get(ManagerEndpoints.datasetVersions(datasetId)),
        DatasetVersionModel.fromJson,
      );

  Future<DatasetVersionModel> restoreDatasetVersion(String versionId) =>
      _unwrap(
        () =>
            _dioClient.post(ManagerEndpoints.datasetVersionRestore(versionId)),
        (data) => DatasetVersionModel.fromJson(data as Map<String, dynamic>),
      );

  // ================= LABELS =================

  Future<List<LabelModel>> getLabels(String projectId) => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.projectLabels(projectId)),
    LabelModel.fromJson,
  );

  Future<LabelModel> createLabel({
    required String projectId,
    required String name,
    required int yoloClassId,
    String? categoryId,
    String? annotationTypeId,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.labels,
      data: {
        'projectId': projectId,
        'name': name,
        'yoloClassId': yoloClassId,
        'categoryId': ?categoryId,
        'annotationTypeId': ?annotationTypeId,
      },
    ),
    (data) => LabelModel.fromJson(data as Map<String, dynamic>),
  );

  Future<LabelModel> updateLabel(
    String labelId, {
    required String name,
    required int yoloClassId,
    String? categoryId,
    String? annotationTypeId,
  }) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.label(labelId),
      data: {
        'name': name,
        'yoloClassId': yoloClassId,
        'categoryId': ?categoryId,
        'annotationTypeId': ?annotationTypeId,
      },
    ),
    (data) => LabelModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteLabel(String labelId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.label(labelId)),
    (data) => data as bool,
  );

  // ================= LABEL CATEGORIES =================

  Future<List<LabelCategoryModel>> getLabelCategories(String projectId) =>
      _unwrapList(
        () =>
            _dioClient.get(ManagerEndpoints.projectLabelCategories(projectId)),
        LabelCategoryModel.fromJson,
      );

  Future<LabelCategoryModel> createLabelCategory({
    required String projectId,
    required String name,
    String? description,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.labelCategories,
      data: {'projectId': projectId, 'name': name, 'description': ?description},
    ),
    (data) => LabelCategoryModel.fromJson(data as Map<String, dynamic>),
  );

  Future<LabelCategoryModel> updateLabelCategory(
    String categoryId, {
    required String name,
    String? description,
  }) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.labelCategory(categoryId),
      data: {'name': name, 'description': ?description},
    ),
    (data) => LabelCategoryModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteLabelCategory(String categoryId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.labelCategory(categoryId)),
    (data) => data as bool,
  );

  // ================= ANNOTATION TYPES =================

  Future<List<AnnotationTypeModel>> getAnnotationTypes(String projectId) =>
      _unwrapList(
        () =>
            _dioClient.get(ManagerEndpoints.projectAnnotationTypes(projectId)),
        AnnotationTypeModel.fromJson,
      );

  Future<AnnotationTypeModel> createAnnotationType({
    required String projectId,
    required String name,
    String? description,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.annotationTypes,
      data: {'projectId': projectId, 'name': name, 'description': ?description},
    ),
    (data) => AnnotationTypeModel.fromJson(data as Map<String, dynamic>),
  );

  Future<AnnotationTypeModel> updateAnnotationType(
    String annotationTypeId, {
    required String name,
    String? description,
  }) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.annotationType(annotationTypeId),
      data: {'name': name, 'description': ?description},
    ),
    (data) => AnnotationTypeModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteAnnotationType(String annotationTypeId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.annotationType(annotationTypeId)),
    (data) => data as bool,
  );

  // ================= TASKS =================

  Future<ManagerTaskModel> createTask({
    required String projectId,
    required String dataItemId,
    required String annotatorId,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.tasks,
      data: {
        'projectId': projectId,
        'dataItemId': dataItemId,
        'annotatorId': annotatorId,
      },
    ),
    (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
  );

  Future<int> bulkCreateTasksByDataset({
    required String projectId,
    required String datasetId,
    required String annotatorId,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.tasksBulkCreateByDataset,
      data: {
        'projectId': projectId,
        'datasetId': datasetId,
        'annotatorId': annotatorId,
      },
    ),
    (data) => data as int,
  );

  Future<ManagerTaskModel> assignTask(String taskId, String annotatorId) =>
      _unwrap(
        () => _dioClient.post(
          ManagerEndpoints.taskAssign(taskId),
          data: {'annotatorId': annotatorId},
        ),
        (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
      );

  Future<int> bulkAssignTasks({
    required List<String> taskIds,
    required String annotatorId,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.tasksBulkAssign,
      data: {'taskIds': taskIds, 'annotatorId': annotatorId},
    ),
    (data) => data as int,
  );

  Future<ManagerTaskModel> reassignTask(String taskId, String annotatorId) =>
      _unwrap(
        () => _dioClient.post(
          ManagerEndpoints.taskReassign(taskId),
          data: {'annotatorId': annotatorId},
        ),
        (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
      );

  Future<ManagerTaskModel> pauseTask(String taskId) => _unwrap(
    () => _dioClient.post(ManagerEndpoints.taskPause(taskId)),
    (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ManagerTaskModel> resumeTask(String taskId) => _unwrap(
    () => _dioClient.post(ManagerEndpoints.taskResume(taskId)),
    (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ManagerTaskModel> cancelTask(String taskId) => _unwrap(
    () => _dioClient.post(ManagerEndpoints.taskCancel(taskId)),
    (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ManagerTaskModel> requestRelabeling(String taskId, String reason) =>
      _unwrap(
        () => _dioClient.post(
          ManagerEndpoints.taskRelabel(taskId),
          data: {'reason': reason},
        ),
        (data) => ManagerTaskModel.fromJson(data as Map<String, dynamic>),
      );

  Future<List<ManagerTaskModel>> getProjectTasks(String projectId) =>
      _unwrapList(
        () => _dioClient.get(ManagerEndpoints.projectTasks(projectId)),
        ManagerTaskModel.fromJson,
      );

  Future<TaskProgressModel> getTaskProgress(String projectId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.projectTaskProgress(projectId)),
    (data) => TaskProgressModel.fromJson(data as Map<String, dynamic>),
  );

  Future<List<TaskHistoryModel>> getTaskHistory(String taskId) => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.taskHistory(taskId)),
    TaskHistoryModel.fromJson,
  );

  // ================= MONITORING =================

  Future<LabelingProgressOverviewModel> getLabelingOverview(String projectId) =>
      _unwrap(
        () => _dioClient.get(ManagerEndpoints.monitoringOverview(projectId)),
        (data) => LabelingProgressOverviewModel.fromJson(
          data as Map<String, dynamic>,
        ),
      );

  Future<List<AnnotatorPerformanceModel>> getAnnotatorPerformance(
    String projectId,
  ) => _unwrapList(
    () => _dioClient.get(
      ManagerEndpoints.monitoringAnnotatorPerformance(projectId),
    ),
    AnnotatorPerformanceModel.fromJson,
  );

  Future<ReviewStatisticsModel> getReviewStats(String projectId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.monitoringReviewStats(projectId)),
    (data) => ReviewStatisticsModel.fromJson(data as Map<String, dynamic>),
  );

  Future<List<InconsistentLabelModel>> getInconsistentLabels(
    String projectId,
  ) => _unwrapList(
    () => _dioClient.get(
      ManagerEndpoints.monitoringInconsistentLabels(projectId),
    ),
    InconsistentLabelModel.fromJson,
  );

  Future<QualityReportModel> getQualityReport(String projectId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.monitoringQualityReport(projectId)),
    (data) => QualityReportModel.fromJson(data as Map<String, dynamic>),
  );

  // ================= EXPORTS =================

  Future<ExportModel> createExport({
    required String projectId,
    required String format,
    required String exportPath,
    required String labelFormat,
    List<String>? includeFields,
    Map<String, String>? filters,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.exports,
      data: {
        'projectId': projectId,
        'format': format,
        'exportPath': exportPath,
        'labelFormat': labelFormat,
        'includeFields': ?includeFields,
        'filters': ?filters,
      },
    ),
    (data) => ExportModel.fromJson(data as Map<String, dynamic>),
  );

  Future<List<ExportModel>> getProjectExports(String projectId) => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.projectExports(projectId)),
    ExportModel.fromJson,
  );

  Future<ExportValidationModel> validateApprovedData(String projectId) =>
      _unwrap(
        () =>
            _dioClient.get(ManagerEndpoints.projectExportsValidate(projectId)),
        (data) => ExportValidationModel.fromJson(data as Map<String, dynamic>),
      );

  Future<List<int>> downloadExport(String exportId) async {
    try {
      final response = await _dioClient.get(
        ManagerEndpoints.exportDownload(exportId),
        options: Options(responseType: ResponseType.bytes),
      );
      return List<int>.from(response.data as List);
    } catch (e) {
      Logger.error('❌ Export download failed: $e');
      rethrow;
    }
  }

  // ================= ACTIVITY LOGS =================

  Future<List<ActivityLogModel>> getActivityLogs({
    String? projectId,
    String? userId,
    int page = 1,
    int pageSize = 50,
  }) => _unwrapList(
    () => _dioClient.get(
      ManagerEndpoints.activityLogs,
      queryParameters: {
        'projectId': ?projectId,
        'userId': ?userId,
        'page': page,
        'pageSize': pageSize,
      },
    ),
    ActivityLogModel.fromJson,
  );

  // ================= USERS =================

  Future<List<UserModel>> getUsers() => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.users),
    UserModel.fromJson,
  );

  Future<UserModel> getUserById(String userId) => _unwrap(
    () => _dioClient.get(ManagerEndpoints.user(userId)),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );

  Future<UserModel> createUser({
    required String fullName,
    required String email,
    required String password,
    required String roleId,
    int status = UserAccountStatus.active,
    String? phoneNumber,
  }) => _unwrap(
    () => _dioClient.post(
      ManagerEndpoints.users,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'roleId': roleId,
        'status': status,
        'phoneNumber': ?phoneNumber,
      },
    ),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );

  Future<UserModel> updateUser({
    required String userId,
    required String fullName,
    required String email,
    required String roleId,
    required int status,
    String? password,
    String? phoneNumber,
  }) => _unwrap(
    () => _dioClient.put(
      ManagerEndpoints.user(userId),
      data: {
        'fullName': fullName,
        'email': email,
        'roleId': roleId,
        'status': status,
        'password': password,
        'phoneNumber': phoneNumber,
      },
    ),
    (data) => UserModel.fromJson(data as Map<String, dynamic>),
  );

  Future<bool> deleteUser(String userId) => _unwrap(
    () => _dioClient.delete(ManagerEndpoints.user(userId)),
    (data) => data as bool,
  );

  Future<List<RoleModel>> getRoles() => _unwrapList(
    () => _dioClient.get(ManagerEndpoints.roles),
    RoleModel.fromJson,
  );

  Future<List<UserSummaryModel>> searchUsers({
    required String query,
    String? role,
  }) => _unwrapList(
    () => _dioClient.get(
      ManagerEndpoints.usersSearch,
      queryParameters: {'q': query, 'role': ?role},
    ),
    UserSummaryModel.fromJson,
  );
}
