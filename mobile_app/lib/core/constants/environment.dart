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
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';

  // Annotator endpoints
  static const String getTasksEndpoint = '/annotator/tasks';
  static const String getTaskItemsEndpoint = '/annotator/tasks/{taskId}/items';
  static const String getTaskLabelsEndpoint = '/annotator/tasks/{taskId}/labels';
  static const String getTaskGuidelineEndpoint =
      '/annotator/tasks/{taskId}/guideline';
  static const String getTaskDataItemEndpoint =
      '/annotator/tasks/{taskId}/data-item/content';
  static const String acceptTaskEndpoint = '/annotator/tasks/{taskId}/accept';
  static const String startTaskEndpoint = '/annotator/tasks/{taskId}/start';
  static const String getTaskAnnotationsEndpoint =
      '/annotator/tasks/{taskId}/annotations';
  static const String submitTaskEndpoint =
      '/annotator/tasks/{taskId}/annotations/submit';

  // Full endpoint builders
  static String getFullUrl(String endpoint) => '$baseUrl$endpoint';
}
