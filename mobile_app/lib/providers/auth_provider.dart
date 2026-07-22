import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import '../models/auth/resend_email_verification_request.dart';
import '../models/auth/verify_email_otp_request.dart';
import '../models/auth/user_profile.dart';
import '../models/common/api_error.dart';
import '../models/manager/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  UserProfile? _userProfile;
  UserModel? _profileDetail;
  String? _errorMessage;
  String? _accessToken;
  bool _profileBusy = false;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  // Getters
  AuthState get state => _state;
  UserProfile? get userProfile => _userProfile;
  UserModel? get profileDetail => _profileDetail;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isProfileBusy => _profileBusy;

  /// Initialize authentication state on app startup
  Future<void> initialize() async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        _userProfile = await _authRepository.getStoredUserProfile();
        _state = AuthState.authenticated;
        Logger.info('✅ User already authenticated on startup');
      } else {
        _state = AuthState.unauthenticated;
        Logger.info('ℹ️ User not authenticated on startup');
      }
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Failed to initialize auth: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final request = LoginRequest(
        email: email.trim(),
        password: password.trim(),
      );
      final authResponse = await _authRepository.login(request);

      _accessToken = authResponse.accessToken;
      _userProfile = authResponse.user;
      _state = AuthState.authenticated;
      _errorMessage = null;

      Logger.info('✅ Login successful: ${authResponse.user.fullName}');
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      Logger.error('❌ Login failed: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected login error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Register new user and send verification OTP
  Future<RegisterResponse?> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final request = RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      final registerResponse = await _authRepository.register(request);
      _state = AuthState.unauthenticated;
      _errorMessage = null;

      Logger.info('✅ Registration OTP sent to: ${registerResponse.email}');
      notifyListeners();
      return registerResponse;
    } on ApiError catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      Logger.error('❌ Registration failed: ${e.message}');
      notifyListeners();
      return null;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected registration error: $e');
      notifyListeners();
      return null;
    }
  }

  /// Verify email OTP and sign in
  Future<bool> verifyEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final request = VerifyEmailOtpRequest(email: email, otpCode: otpCode);
      final authResponse = await _authRepository.verifyEmailOtp(request);

      _accessToken = authResponse.accessToken;
      _userProfile = authResponse.user;
      _state = AuthState.authenticated;
      _errorMessage = null;

      Logger.info('✅ Email verified: ${authResponse.user.fullName}');
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      Logger.error('❌ Email verification failed: ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Unexpected email verification error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Resend verification OTP
  Future<RegisterResponse?> resendVerificationOtp(String email) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _authRepository.resendVerificationOtp(
        ResendEmailVerificationRequest(email: email),
      );

      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return response;
    } on ApiError catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      await _authRepository.logout();

      _accessToken = null;
      _userProfile = null;
      _profileDetail = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;

      Logger.info('✅ Logout successful');
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = AppConstants.errorGeneric;
      Logger.error('❌ Logout failed: $e');
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load full profile for the current user
  Future<UserModel?> fetchProfile() async {
    try {
      _profileBusy = true;
      _errorMessage = null;
      notifyListeners();

      final profile = await _authRepository.getMe();
      _profileDetail = profile;
      _userProfile = UserProfile(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        roleId: profile.roleId,
        roleName: profile.roleName,
        status: profile.status,
      );
      _profileBusy = false;
      notifyListeners();
      return profile;
    } on ApiError catch (e) {
      _profileBusy = false;
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _profileBusy = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return null;
    }
  }

  /// Update current user profile fields
  Future<bool> updateProfile({
    required String fullName,
    required String email,
    String? phoneNumber,
    String? identifyNumber,
    String? gender,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    try {
      _profileBusy = true;
      _errorMessage = null;
      notifyListeners();

      final profile = await _authRepository.updateMe(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        identifyNumber: identifyNumber,
        gender: gender,
        address: address,
        dateOfBirth: dateOfBirth,
      );

      _profileDetail = profile;
      _userProfile = UserProfile(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        roleId: profile.roleId,
        roleName: profile.roleName,
        status: profile.status,
      );
      _profileBusy = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _profileBusy = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _profileBusy = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }

  /// Delete current account and clear local session
  Future<bool> deleteAccount() async {
    try {
      _profileBusy = true;
      _errorMessage = null;
      notifyListeners();

      await _authRepository.deleteMe();

      _accessToken = null;
      _userProfile = null;
      _profileDetail = null;
      _state = AuthState.unauthenticated;
      _profileBusy = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _profileBusy = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _profileBusy = false;
      _errorMessage = AppConstants.errorGeneric;
      notifyListeners();
      return false;
    }
  }
}
