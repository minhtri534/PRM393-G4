import 'package:dio/dio.dart';

import '../core/constants/chat_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../models/chat/chat_models.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import 'dio_client.dart';

class ChatRepository {
  final DioClient _dioClient;

  ChatRepository({DioClient? dioClient})
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
        code: 'CHAT_API_FAILED',
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

  Future<List<MyProjectSummaryModel>> getProjects() => _unwrapList(
    () => _dioClient.get(ChatEndpoints.projects),
    MyProjectSummaryModel.fromJson,
  );

  Future<List<ChatMessageModel>> getMessages(
    String projectId, {
    int page = 1,
    int pageSize = 50,
  }) => _unwrapList(
    () => _dioClient.get(
      ChatEndpoints.projectMessages(projectId),
      queryParameters: {'page': page, 'pageSize': pageSize},
    ),
    ChatMessageModel.fromJson,
  );

  Future<ChatMessageModel> sendTextMessage({
    required String projectId,
    required String content,
  }) => _unwrap(
    () => _dioClient.post(
      ChatEndpoints.projectMessages(projectId),
      data: {'content': content},
    ),
    (data) => ChatMessageModel.fromJson(data as Map<String, dynamic>),
  );

  Future<ChatMessageModel> sendAttachment({
    required String projectId,
    required String filePath,
    String? fileName,
    String? caption,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (caption != null && caption.trim().isNotEmpty)
        'caption': caption.trim(),
    });

    return _unwrap(
      () => _dioClient.post(
        ChatEndpoints.projectAttachment(projectId),
        data: formData,
      ),
      (data) => ChatMessageModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<int>> downloadAttachment(String messageId) async {
    final response = await _dioClient.get(
      ChatEndpoints.messageAttachment(messageId),
      options: Options(responseType: ResponseType.bytes),
    );
    return (response.data as List<int>?) ?? [];
  }
}
