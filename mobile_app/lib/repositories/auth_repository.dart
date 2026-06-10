import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/environment.dart';
import '../core/utils/logger.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import 'dio_client.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    DioClient? dioClient,
    FlutterSecureStorage? secureStorage,
  })  : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post(
        Environment.loginEndpoint,
        data: request.toJson(),
      );

      final serviceResponse = ServiceResponse.fromJson(
        response.data,
        (data) => AuthResponse.fromJson(data),
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              AppConstants.errorGeneric,
          code: 'LOGIN_FAILED',
        );
      }

      final authResponse = serviceResponse.data;
      if (authResponse == null) {
        throw ApiError(
          message: 'Invalid response from server',
          code: 'INVALID_RESPONSE',
        );
      }

      // Store tokens securely
      await _dioClient.setAuthToken(authResponse.accessToken);
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      );
      await _secureStorage.write(
        key: AppConstants.userProfileKey,
        value: _encodeUserProfile(authResponse.user),
      );

      Logger.info('✅ Login successful for user: ${authResponse.user.email}');
      return authResponse;
    } catch (e) {
      Logger.error('❌ Login failed: $e');
      rethrow;
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        Environment.registerEndpoint,
        data: request.toJson(),
      );

      final serviceResponse = ServiceResponse.fromJson(
        response.data,
        (data) => AuthResponse.fromJson(data),
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message ??
              AppConstants.errorGeneric,
          code: 'REGISTER_FAILED',
        );
      }

      final authResponse = serviceResponse.data;
      if (authResponse == null) {
        throw ApiError(
          message: 'Invalid response from server',
          code: 'INVALID_RESPONSE',
        );
      }

      // Store tokens securely
      await _dioClient.setAuthToken(authResponse.accessToken);
      await _secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      );
      await _secureStorage.write(
        key: AppConstants.userProfileKey,
        value: _encodeUserProfile(authResponse.user),
      );

      Logger.info(
        '✅ Registration successful for user: ${authResponse.user.email}',
      );
      return authResponse;
    } catch (e) {
      Logger.error('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      await _dioClient.post(
        Environment.logoutEndpoint,
        data: {
          'refreshToken': refreshToken,
        },
      );

      await _dioClient.clearAuthToken();

      await _secureStorage.delete(
        key: AppConstants.refreshTokenKey,
      );

      await _secureStorage.delete(
        key: AppConstants.userProfileKey,
      );
    } catch (e) {
      await _dioClient.clearAuthToken();

      await _secureStorage.delete(
        key: AppConstants.refreshTokenKey,
      );

      await _secureStorage.delete(
        key: AppConstants.userProfileKey,
      );
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _dioClient.hasAuthToken();
  }

  /// Get stored user profile
  Future<String?> getUserProfile() async {
    return await _secureStorage.read(key: AppConstants.userProfileKey);
  }

  /// Encode user profile for storage
  String _encodeUserProfile(dynamic user) {
    // Simple JSON string encoding for storage
    return user.toString();
  }
}
