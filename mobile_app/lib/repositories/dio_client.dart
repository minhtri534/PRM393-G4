import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/environment.dart';
import '../core/storage/app_storage.dart';
import '../core/utils/logger.dart';
import '../../models/common/api_error.dart';

/// HTTP client using Dio for all API communications.
/// Singleton so auth token is shared across repositories (important on Flutter web).
class DioClient {
  DioClient._({AppStorage? storage})
    : _storage = storage ?? AppStorage.instance {
    _initializeDio();
  }

  static DioClient? _instance;

  factory DioClient({AppStorage? storage}) {
    return _instance ??= DioClient._(storage: storage);
  }

  @Deprecated('Use DioClient() factory')
  static DioClient get instance => DioClient();

  late Dio _dio;
  final AppStorage _storage;

  /// In-memory cache — SharedPreferences on Safari/web can lag behind writes.
  String? _cachedToken;

  void _initializeDio() {
    final baseUrl = Environment.baseUrl;
    Logger.info('🌐 API base URL: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.httpTimeout,
        receiveTimeout: AppConstants.httpTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    Logger.debug('🔗 Request: ${options.method} ${options.uri}');

    if (options.data is FormData) {
      options.headers.remove('Content-Type');
    }

    final token =
        _cachedToken ?? await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    Logger.debug(
      '✅ Response: ${response.statusCode} from ${response.requestOptions.path}',
    );
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    Logger.error(
      'ℹ️ Error: ${error.type} - ${error.message}',
      error,
      error.stackTrace,
    );
    return handler.next(error);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String? _extractServerMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  List<String>? _extractServerErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final errors = responseData['errors'];
      if (errors is List) {
        return errors.whereType<String>().toList();
      }
    }
    return null;
  }

  ApiError _handleDioException(DioException error) {
    String message = AppConstants.errorGeneric;
    String? code;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      message = 'Connection timeout. Please check your network.';
      code = 'TIMEOUT';
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      code = 'HTTP_$statusCode';

      final serverMessage = _extractServerMessage(responseData);
      final serverErrors = _extractServerErrors(responseData);

      switch (statusCode) {
        case 400:
          message =
              serverMessage ??
              serverErrors?.first ??
              'Invalid request. Please check your input.';
          break;
        case 401:
          message =
              serverMessage ??
              serverErrors?.first ??
              AppConstants.errorUnauthorized;
          break;
        case 403:
          message = serverMessage ?? 'Access forbidden.';
          break;
        case 404:
          final path = error.requestOptions.uri.toString();
          message = serverMessage ?? 'Resource not found ($path).';
          break;
        case 500:
          message = serverMessage ?? AppConstants.errorServerError;
          break;
        default:
          message = serverMessage ?? AppConstants.errorGeneric;
      }
    } else if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      message = AppConstants.errorNetworkConnection;
      code = 'NETWORK_ERROR';
    }

    return ApiError(message: message, code: code, originalError: error);
  }

  Future<void> setAuthToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> clearAuthToken() async {
    _cachedToken = null;
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<bool> hasAuthToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return true;
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      _cachedToken = token;
      return true;
    }
    return false;
  }
}
