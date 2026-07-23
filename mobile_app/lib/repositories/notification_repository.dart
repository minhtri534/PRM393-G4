import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/manager_endpoints.dart';
import '../core/constants/notification_endpoints.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import '../models/notification/notification_model.dart';
import 'dio_client.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository({DioClient? dioClient})
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
        code: 'NOTIFICATION_API_FAILED',
      );
    }
    if (serviceResponse.data == null) {
      if (T == int) {
        return 0 as T;
      }
      throw ApiError(
        message: 'Invalid response from server',
        code: 'INVALID_RESPONSE',
      );
    }
    return serviceResponse.data as T;
  }

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 30,
    bool unreadOnly = false,
  }) {
    return _unwrap<List<NotificationModel>>(
      () => _dioClient.get(
        NotificationEndpoints.list,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'unreadOnly': unreadOnly,
        },
      ),
      (data) => (data as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<int> getUnreadCount() {
    return _unwrap<int>(
      () => _dioClient.get(NotificationEndpoints.unreadCount),
      (data) => int.tryParse(data?.toString() ?? '') ?? 0,
    );
  }

  Future<int> markRead(List<String> ids) {
    return _unwrap<int>(
      () => _dioClient.post(
        NotificationEndpoints.markRead,
        data: {'ids': ids},
      ),
      (data) => int.tryParse(data?.toString() ?? '') ?? 0,
    );
  }

  Future<int> markAllRead() {
    return _unwrap<int>(
      () => _dioClient.post(NotificationEndpoints.markAllRead),
      (data) => int.tryParse(data?.toString() ?? '') ?? 0,
    );
  }

  Future<int> sendProjectNotification({
    required String projectId,
    required String title,
    String? body,
  }) {
    return _unwrap<int>(
      () => _dioClient.post(
        ManagerEndpoints.projectNotifications(projectId),
        data: {
          'title': title,
          if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
        },
      ),
      (data) => int.tryParse(data?.toString() ?? '') ?? 0,
    );
  }
}
