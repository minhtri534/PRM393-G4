import 'package:dio/dio.dart';

import '../core/constants/annotator_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_models.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import 'dio_client.dart';

class AnnotatorRepository {
  final DioClient _dioClient;

  AnnotatorRepository({DioClient? dioClient})
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
        code: 'ANNOTATOR_API_FAILED',
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

  Future<List<MyProjectSummaryModel>> getProjects() => _unwrapList(
        () => _dioClient.get(AnnotatorEndpoints.projects),
        MyProjectSummaryModel.fromJson,
      );

  Future<List<AnnotatorTaskModel>> getTasks({String? projectId}) => _unwrapList(
        () => _dioClient.get(
          AnnotatorEndpoints.tasks,
          queryParameters: {
            if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
          },
        ),
        AnnotatorTaskModel.fromJson,
      );

  Future<List<AnnotatorTaskItemModel>> getTaskItems(String taskId) =>
      _unwrapList(
        () => _dioClient.get(AnnotatorEndpoints.taskItems(taskId)),
        AnnotatorTaskItemModel.fromJson,
      );

  Future<List<AnnotatorLabelModel>> getTaskLabels(String taskId) => _unwrapList(
        () => _dioClient.get(AnnotatorEndpoints.taskLabels(taskId)),
        AnnotatorLabelModel.fromJson,
      );

  Future<AnnotatorGuidelineModel> getTaskGuideline(String taskId) => _unwrap(
        () => _dioClient.get(AnnotatorEndpoints.taskGuideline(taskId)),
        (data) => AnnotatorGuidelineModel.fromJson(data as Map<String, dynamic>),
      );

  Future<List<AnnotatorAnnotationModel>> getTaskAnnotations(String taskId) =>
      _unwrapList(
        () => _dioClient.get(AnnotatorEndpoints.taskAnnotations(taskId)),
        AnnotatorAnnotationModel.fromJson,
      );

  Future<AnnotatorReviewFeedbackModel?> getTaskReviewFeedback(
    String taskId,
  ) async {
    final response = await _dioClient.get(
      AnnotatorEndpoints.taskReviewFeedback(taskId),
    );
    final serviceResponse = ServiceResponse<AnnotatorReviewFeedbackModel?>.fromJson(
      response.data as Map<String, dynamic>,
      (data) {
        if (data == null) return null;
        if (data is List) {
          if (data.isEmpty) return null;
          return AnnotatorReviewFeedbackModel.fromJson(
            data.first as Map<String, dynamic>,
          );
        }
        return AnnotatorReviewFeedbackModel.fromJson(
          data as Map<String, dynamic>,
        );
      },
    );
    if (!serviceResponse.isSuccess) {
      throw ApiError(
        message: serviceResponse.message.isNotEmpty
            ? serviceResponse.message
            : AppConstants.errorGeneric,
        code: 'ANNOTATOR_API_FAILED',
      );
    }
    return serviceResponse.data;
  }

  Future<bool> acceptTask(String taskId) => _unwrapBool(
        () => _dioClient.post(AnnotatorEndpoints.taskAccept(taskId)),
      );

  Future<bool> rejectTask(String taskId, {String? reason}) => _unwrapBool(
        () => _dioClient.post(
          AnnotatorEndpoints.taskReject(taskId),
          data: {'reason': reason},
        ),
      );

  Future<bool> startTask(String taskId) => _unwrapBool(
        () => _dioClient.post(AnnotatorEndpoints.taskStart(taskId)),
      );

  Future<bool> saveAnnotationDraft(
    String taskId,
    List<LabelingBox> boxes,
  ) =>
      _unwrapBool(
        () => _dioClient.put(
          AnnotatorEndpoints.taskAnnotationsDraft(taskId),
          data: _upsertPayload(boxes),
        ),
      );

  Future<bool> submitAnnotations(
    String taskId,
    List<LabelingBox> boxes,
  ) =>
      _unwrapBool(
        () => _dioClient.post(
          AnnotatorEndpoints.taskAnnotationsSubmit(taskId),
          data: _upsertPayload(boxes),
        ),
      );

  Map<String, dynamic> _upsertPayload(List<LabelingBox> boxes) => {
        'objects': boxes.map((b) => b.toUpsertJson()).toList(),
      };

  Future<List<int>> getTaskDataItemContent(String taskId) async {
    try {
      final response = await _dioClient.get(
        AnnotatorEndpoints.taskDataItemContent(taskId),
        options: Options(responseType: ResponseType.bytes),
      );
      Logger.info('✅ Downloaded task image bytes');
      return (response.data as List<int>?) ?? [];
    } catch (e) {
      Logger.error('❌ Failed to download task image: $e');
      rethrow;
    }
  }
}
