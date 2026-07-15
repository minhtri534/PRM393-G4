import 'package:flutter/foundation.dart';

/// Environment configuration for the mobile app
class Environment {
  // Override at run time:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
  // flutter run --dart-define=API_BASE_URL=https://flinch-captivity-outlook.ngrok-free.dev/api
  //
  // Web / iOS Simulator / desktop: localhost
  // Android Emulator: 10.0.2.2 maps to host machine localhost
  // Physical device: use your machine LAN IP (e.g. 192.168.x.x) or ngrok URL below

  static const String ngrokOrigin = 'https://flinch-captivity-outlook.ngrok-free.dev';
  static const String ngrokApiBaseUrl = '$ngrokOrigin/api';

  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return ngrokApiBaseUrl;
    /*return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5000/api'
        : 'http://localhost:5000/api';*/
  }

  static const String _socketUrlOverride = String.fromEnvironment('SOCKET_URL');

  static String get socketUrl {
    if (_socketUrlOverride.isNotEmpty) {
      return _socketUrlOverride;
    }

    // Keep socket host in sync with API_BASE_URL (port 5000 -> 5001).
    final apiOverride = _apiBaseUrlOverride;
    if (apiOverride.isNotEmpty) {
      return _deriveSocketUrl(apiOverride);
    }

    if (kIsWeb) {
      return 'http://localhost:5001';
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:5001'
        : 'http://localhost:5001';
  }

  static String _deriveSocketUrl(String apiBaseUrl) {
    final parsed = Uri.tryParse(apiBaseUrl);
    if (parsed == null || parsed.host.isEmpty) {
      return 'http://localhost:5001';
    }

    final socketPort = parsed.port == 5000 || parsed.port == 80 ? 5001 : parsed.port;
    return Uri(
      scheme: parsed.scheme.isEmpty ? 'http' : parsed.scheme,
      host: parsed.host,
      port: socketPort,
    ).toString();
  }

  /// API origin without /api suffix — used for attachment URLs.
  static String get apiOrigin {
    final url = baseUrl;
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
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
