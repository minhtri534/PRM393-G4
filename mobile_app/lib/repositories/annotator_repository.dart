import 'package:dio/dio.dart';

import '../core/constants/annotator_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_models.dart';
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

  Future<List<AnnotatorTaskModel>> getTasks() => _unwrapList(
        () => _dioClient.get(AnnotatorEndpoints.tasks),
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

  Future<bool> acceptTask(String taskId) => _unwrap(
        () => _dioClient.post(AnnotatorEndpoints.taskAccept(taskId)),
        (data) => data as bool? ?? true,
      );

  Future<bool> startTask(String taskId) => _unwrap(
        () => _dioClient.post(AnnotatorEndpoints.taskStart(taskId)),
        (data) => data as bool? ?? true,
      );

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
