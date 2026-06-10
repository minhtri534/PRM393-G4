import 'package:flutter/material.dart';
import '../screens/annotator/task_detail_screen.dart';
import '../screens/annotator/task_list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String tasks = '/tasks';
  static const String taskDetail = '/task-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      case tasks:
        return MaterialPageRoute(
          builder: (_) => const TaskListScreen(),
        );
      case taskDetail:
        final taskId = settings.arguments as String?;
        if (taskId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Task ID not provided'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
