import 'package:dio/dio.dart';

import '../core/constants/environment.dart';
import '../core/utils/logger.dart';
import '../models/annotator/annotator_task.dart';
import '../models/annotator/label.dart';
import '../models/annotator/task_item.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import 'dio_client.dart';

class AnnotatorRepository {
  final DioClient _dioClient;

  AnnotatorRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Get all tasks for the current annotator
  Future<List<AnnotatorTask>> getTasks() async {
    try {
      final response = await _dioClient.get(Environment.getTasksEndpoint);

      final serviceResponse = ServiceResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ?? 'Failed to fetch tasks',
          code: 'GET_TASKS_FAILED',
        );
      }

      final tasksData = serviceResponse.data ?? [];
      final tasks = tasksData
          .map((taskJson) => AnnotatorTask.fromJson(taskJson))
          .toList();

      Logger.info('✅ Fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      Logger.error('❌ Failed to get tasks: $e');
      rethrow;
    }
  }

  /// Get task items for a specific task
  Future<List<TaskItem>> getTaskItems(String taskId) async {
    try {
      final endpoint =
          Environment.getTaskItemsEndpoint.replaceFirst('{taskId}', taskId);
      final response = await _dioClient.get(endpoint);

      final serviceResponse = ServiceResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              'Failed to fetch task items',
          code: 'GET_TASK_ITEMS_FAILED',
        );
      }

      final itemsData = serviceResponse.data ?? [];
      final items = itemsData
          .map((itemJson) => TaskItem.fromJson(itemJson))
          .toList();

      Logger.info('✅ Fetched ${items.length} task items');
      return items;
    } catch (e) {
      Logger.error('❌ Failed to get task items: $e');
      rethrow;
    }
  }

  /// Get labels for a specific task
  Future<List<Label>> getTaskLabels(String taskId) async {
    try {
      final endpoint =
          Environment.getTaskLabelsEndpoint.replaceFirst('{taskId}', taskId);
      final response = await _dioClient.get(endpoint);

      final serviceResponse = ServiceResponse<List<dynamic>>.fromJson(
        response.data,
        (data) => data as List<dynamic>,
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              'Failed to fetch labels',
          code: 'GET_LABELS_FAILED',
        );
      }

      final labelsData = serviceResponse.data ?? [];
      final labels = labelsData
          .map((labelJson) => Label.fromJson(labelJson))
          .toList();

      Logger.info('✅ Fetched ${labels.length} labels');
      return labels;
    } catch (e) {
      Logger.error('❌ Failed to get labels: $e');
      rethrow;
    }
  }

  /// Accept a task
  Future<bool> acceptTask(String taskId) async {
    try {
      final endpoint = Environment.acceptTaskEndpoint
          .replaceFirst('{taskId}', taskId);
      final response = await _dioClient.post(endpoint);

      final serviceResponse = ServiceResponse<bool>.fromJson(
        response.data,
        (data) => data as bool? ?? false,
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              'Failed to accept task',
          code: 'ACCEPT_TASK_FAILED',
        );
      }

      Logger.info('✅ Task $taskId accepted');
      return true;
    } catch (e) {
      Logger.error('❌ Failed to accept task: $e');
      rethrow;
    }
  }

  /// Start a task
  Future<bool> startTask(String taskId) async {
    try {
      final endpoint =
          Environment.startTaskEndpoint.replaceFirst('{taskId}', taskId);
      final response = await _dioClient.post(endpoint);

      final serviceResponse = ServiceResponse<bool>.fromJson(
        response.data,
        (data) => data as bool? ?? false,
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              'Failed to start task',
          code: 'START_TASK_FAILED',
        );
      }

      Logger.info('✅ Task $taskId started');
      return true;
    } catch (e) {
      Logger.error('❌ Failed to start task: $e');
      rethrow;
    }
  }

  /// Get task data item content (download file)
  Future<List<int>> getTaskDataItemContent(String taskId) async {
    try {
      final endpoint = Environment.getTaskDataItemEndpoint
          .replaceFirst('{taskId}', taskId);
      final response = await _dioClient.get(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );

      Logger.info('✅ Downloaded task data item');
      return response.data as List<int>;
    } catch (e) {
      Logger.error('❌ Failed to download task data: $e');
      rethrow;
    }
  }
}
