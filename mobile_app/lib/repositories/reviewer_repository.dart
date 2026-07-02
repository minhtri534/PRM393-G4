import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/chat_endpoints.dart';
import '../core/constants/reviewer_endpoints.dart';
import '../core/utils/logger.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import '../models/reviewer/reviewer_models.dart';
import 'dio_client.dart';

class ReviewerRepository {
  final DioClient _dioClient;

  ReviewerRepository({DioClient? dioClient})
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
        code: 'REVIEWER_API_FAILED',
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

  Future<bool> _unwrapBool(Future<Response<dynamic>> Function() request) =>
      _unwrap(request, (data) => data as bool? ?? true);

  Future<List<MyProjectSummaryModel>> getProjects() async {
    try {
      return await _unwrapList(
        () => _dioClient.get(ReviewerEndpoints.projects),
        MyProjectSummaryModel.fromJson,
      );
    } on ApiError catch (e) {
      if (e.code != 'HTTP_404') rethrow;
      Logger.info(
        'Reviewer /projects not found — using chat + submitted fallback',
      );
      return _getProjectsFallback();
    }
  }

  Future<List<MyProjectSummaryModel>> _getProjectsFallback() async {
    final submitted = await getSubmittedTasks();
    final pendingByProject = <String, int>{};
    for (final task in submitted) {
      pendingByProject.update(task.projectId, (v) => v + 1, ifAbsent: () => 1);
    }

    try {
      final chatProjects = await _unwrapList(
        () => _dioClient.get(ChatEndpoints.projects),
        MyProjectSummaryModel.fromJson,
      );
      if (chatProjects.isNotEmpty) {
        return chatProjects
            .map(
              (project) => MyProjectSummaryModel(
                id: project.id,
                name: project.name,
                guideline: project.guideline,
                todoTaskCount: pendingByProject[project.id] ?? 0,
                doneTaskCount: 0,
                lastChatMessageAt: project.lastChatMessageAt,
                lastChatMessagePreview: project.lastChatMessagePreview,
              ),
            )
            .toList();
      }
    } catch (e) {
      Logger.error('Chat projects fallback failed: $e');
    }

    final names = <String, String>{};
    for (final task in submitted) {
      names[task.projectId] = task.projectName;
    }

    return pendingByProject.keys.map((projectId) {
      return MyProjectSummaryModel(
        id: projectId,
        name: names[projectId] ?? 'Project',
        guideline: null,
        todoTaskCount: pendingByProject[projectId] ?? 0,
        doneTaskCount: 0,
      );
    }).toList();
  }

  Future<List<ReviewerSubmittedTaskModel>> getSubmittedTasks({
    String? projectId,
  }) => _unwrapList(
    () => _dioClient.get(
      ReviewerEndpoints.submittedTasks,
      queryParameters: {
        if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
      },
    ),
    ReviewerSubmittedTaskModel.fromJson,
  );

  Future<ReviewerLabeledDataModel> getLabeledData(String taskId) => _unwrap(
    () => _dioClient.get(ReviewerEndpoints.labeledData(taskId)),
    (data) => ReviewerLabeledDataModel.fromJson(data as Map<String, dynamic>),
  );

  Future<GuidelineComparisonModel> getGuidelineComparison(String taskId) =>
      _unwrap(
        () => _dioClient.get(ReviewerEndpoints.guidelineComparison(taskId)),
        (data) =>
            GuidelineComparisonModel.fromJson(data as Map<String, dynamic>),
      );

  Future<LabelConsistencyModel> getConsistencyValidation(String taskId) =>
      _unwrap(
        () => _dioClient.get(ReviewerEndpoints.consistencyValidation(taskId)),
        (data) => LabelConsistencyModel.fromJson(data as Map<String, dynamic>),
      );

  Future<List<ReviewerErrorTypeModel>> getErrorTypes() => _unwrapList(
    () => _dioClient.get(ReviewerEndpoints.errorTypes),
    ReviewerErrorTypeModel.fromJson,
  );

  Future<bool> approveTask(
    String taskId, {
    required int score,
    String? comment,
  }) => _unwrapBool(
    () => _dioClient.post(
      ReviewerEndpoints.approveTask(taskId),
      data: {
        'score': score,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    ),
  );

  Future<bool> returnTask(
    String taskId, {
    required String feedback,
    required int score,
    List<String>? errorTypeIds,
  }) => _unwrapBool(
    () => _dioClient.post(
      ReviewerEndpoints.returnTask(taskId),
      data: {
        'feedback': feedback.trim(),
        'score': score,
        if (errorTypeIds != null && errorTypeIds.isNotEmpty)
          'errorTypeIds': errorTypeIds,
      },
    ),
  );

  Future<List<int>> getTaskContent(String taskId) async {
    try {
      final response = await _dioClient.get(
        ReviewerEndpoints.taskContent(taskId),
        options: Options(responseType: ResponseType.bytes),
      );
      Logger.info('✅ Downloaded reviewer task image bytes');
      return (response.data as List<int>?) ?? [];
    } catch (e) {
      Logger.error('❌ Failed to download reviewer task image: $e');
      rethrow;
    }
  }
}
