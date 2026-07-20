import 'dart:convert';

import '../core/constants/app_constants.dart';
import '../core/constants/environment.dart';
import '../core/storage/app_storage.dart';
import '../core/utils/logger.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/user_profile.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import '../models/auth/resend_email_verification_request.dart';
import '../models/auth/verify_email_otp_request.dart';
import '../models/common/api_error.dart';
import '../models/common/service_response.dart';
import 'dio_client.dart';

class AuthRepository {
  final DioClient _dioClient;
  final AppStorage _storage;

  AuthRepository({DioClient? dioClient, AppStorage? storage})
    : _dioClient = dioClient ?? DioClient(),
      _storage = storage ?? AppStorage.instance;

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
          message: serviceResponse.message ?? AppConstants.errorGeneric,
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
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      );
      await _storage.write(
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

  /// Register new user (sends email verification OTP)
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        Environment.registerEndpoint,
        data: request.toJson(),
      );

      final serviceResponse = ServiceResponse.fromJson(
        response.data,
        (data) => RegisterResponse.fromJson(data as Map<String, dynamic>),
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message.isNotEmpty
              ? serviceResponse.message
              : AppConstants.errorGeneric,
          code: 'REGISTER_FAILED',
        );
      }

      final registerResponse = serviceResponse.data;
      if (registerResponse == null) {
        throw ApiError(
          message: 'Invalid response from server',
          code: 'INVALID_RESPONSE',
        );
      }

      Logger.info(
        '✅ Registration initiated for user: ${registerResponse.email}',
      );
      return registerResponse;
    } catch (e) {
      Logger.error('❌ Registration failed: $e');
      rethrow;
    }
  }

  /// Verify email OTP and complete registration login
  Future<AuthResponse> verifyEmailOtp(VerifyEmailOtpRequest request) async {
    try {
      final response = await _dioClient.post(
        Environment.verifyEmailOtpEndpoint,
        data: request.toJson(),
      );

      final serviceResponse = ServiceResponse.fromJson(
        response.data,
        (data) => AuthResponse.fromJson(data),
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message.isNotEmpty
              ? serviceResponse.message
              : AppConstants.errorGeneric,
          code: 'VERIFY_EMAIL_FAILED',
        );
      }

      final authResponse = serviceResponse.data;
      if (authResponse == null) {
        throw ApiError(
          message: 'Invalid response from server',
          code: 'INVALID_RESPONSE',
        );
      }

      await _dioClient.setAuthToken(authResponse.accessToken);
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      );
      await _storage.write(
        key: AppConstants.userProfileKey,
        value: _encodeUserProfile(authResponse.user),
      );

      Logger.info('✅ Email verified for user: ${authResponse.user.email}');
      return authResponse;
    } catch (e) {
      Logger.error('❌ Email verification failed: $e');
      rethrow;
    }
  }

  /// Resend email verification OTP
  Future<RegisterResponse> resendVerificationOtp(
    ResendEmailVerificationRequest request,
  ) async {
    try {
      final response = await _dioClient.post(
        Environment.resendVerificationOtpEndpoint,
        data: request.toJson(),
      );

      final serviceResponse = ServiceResponse.fromJson(
        response.data,
        (data) => RegisterResponse.fromJson(data as Map<String, dynamic>),
      );

      if (!serviceResponse.isSuccess) {
        throw ApiError(
          message: serviceResponse.message.isNotEmpty
              ? serviceResponse.message
              : AppConstants.errorGeneric,
          code: 'RESEND_OTP_FAILED',
        );
      }

      final registerResponse = serviceResponse.data;
      if (registerResponse == null) {
        throw ApiError(
          message: 'Invalid response from server',
          code: 'INVALID_RESPONSE',
        );
      }

      Logger.info('✅ Verification OTP resent to: ${registerResponse.email}');
      return registerResponse;
    } catch (e) {
      Logger.error('❌ Resend verification OTP failed: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.refreshTokenKey,
      );

      await _dioClient.post(
        Environment.logoutEndpoint,
        data: {'refreshToken': refreshToken},
      );

      await _dioClient.clearAuthToken();

      await _storage.delete(key: AppConstants.refreshTokenKey);

      await _storage.delete(key: AppConstants.userProfileKey);
    } catch (e) {
      await _dioClient.clearAuthToken();

      await _storage.delete(key: AppConstants.refreshTokenKey);

      await _storage.delete(key: AppConstants.userProfileKey);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _dioClient.hasAuthToken();
  }

  /// Get stored user profile
  Future<UserProfile?> getStoredUserProfile() async {
    final raw = await _storage.read(key: AppConstants.userProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String _encodeUserProfile(UserProfile user) => jsonEncode(user.toJson());
}
