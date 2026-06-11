import 'package:flutter/material.dart';

import '../screens/annotator/annotator_shell_screen.dart';
import '../screens/annotator/task_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/manager/dataset_detail_screen.dart';
import '../screens/manager/dataset_upload_screen.dart';
import '../screens/manager/manager_shell_screen.dart';
import '../screens/manager/project_create_screen.dart';
import '../screens/manager/project_detail_screen.dart';
import '../screens/manager/task_create_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Annotator routes
  static const String annotatorHome = '/annotator';
  static const String annotatorTaskDetail = '/annotator/tasks/detail';

  // Manager routes
  static const String managerHome = '/manager';
  static const String managerProjectCreate = '/manager/projects/create';
  static const String managerProjectDetail = '/manager/projects/detail';
  static const String managerDatasetUpload = '/manager/datasets/upload';
  static const String managerDatasetDetail = '/manager/datasets/detail';
  static const String managerTaskCreate = '/manager/tasks/create';

  /// Legacy alias kept for older navigation calls.
  static const String tasks = annotatorHome;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case annotatorHome:
        return MaterialPageRoute(builder: (_) => const AnnotatorShellScreen());
      case annotatorTaskDetail:
        final taskId = settings.arguments as String?;
        if (taskId == null) {
          return _errorRoute('Task ID not provided');
        }
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        );
      case managerHome:
        return MaterialPageRoute(builder: (_) => const ManagerShellScreen());
      case managerProjectCreate:
        return MaterialPageRoute(builder: (_) => const ProjectCreateScreen());
      case managerProjectDetail:
        final projectId = settings.arguments as String?;
        if (projectId == null) {
          return _errorRoute('Project ID not provided');
        }
        return MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: projectId),
        );
      case managerDatasetUpload:
        return MaterialPageRoute(builder: (_) => const DatasetUploadScreen());
      case managerDatasetDetail:
        final datasetId = settings.arguments as String?;
        if (datasetId == null) {
          return _errorRoute('Dataset ID not provided');
        }
        return MaterialPageRoute(
          builder: (_) => DatasetDetailScreen(datasetId: datasetId),
        );
      case managerTaskCreate:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => TaskCreateScreen(initialProjectId: projectId),
        );
      default:
        return _errorRoute('Route not found');
    }
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
