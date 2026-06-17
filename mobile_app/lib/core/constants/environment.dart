import 'package:flutter/foundation.dart';

/// Environment configuration for the mobile app
class Environment {
  // Web / iOS Simulator / desktop: localhost
  // Android Emulator: 10.0.2.2 maps to host machine localhost
  // Physical device: use your machine LAN IP (e.g. 192.168.x.x)

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/api'
        : 'http://localhost:5000/api';
  }

  static const String apiPath = '/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String verifyEmailOtpEndpoint = '/auth/verify-email-otp';
  static const String resendVerificationOtpEndpoint = '/auth/resend-verification-otp';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // Full endpoint builders
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
