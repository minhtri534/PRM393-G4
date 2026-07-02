import 'package:flutter/material.dart';

import '../screens/annotator/annotator_shell_screen.dart';
import '../screens/annotator/chat_room_screen.dart';
import '../screens/annotator/labeling_screen.dart';
import '../screens/annotator/project_tasks_screen.dart';
import '../screens/annotator/task_detail_screen.dart';
import '../models/chat/chat_models.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/manager/dataset_detail_screen.dart';
import '../screens/manager/dataset_upload_screen.dart';
import '../screens/manager/manager_shell_screen.dart';
import '../screens/manager/project_create_screen.dart';
import '../screens/manager/project_detail_screen.dart';
import '../screens/manager/task_create_screen.dart';
import '../screens/manager/user_form_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/reviewer/reviewer_project_tasks_screen.dart';
import '../screens/reviewer/reviewer_shell_screen.dart';
import '../screens/reviewer/reviewer_task_detail_screen.dart';
import '../screens/manager/payment_list_screen.dart';
import '../screens/manager/payment_detail_screen.dart';
import '../screens/manager/payment_history_screen.dart';
import '../screens/manager/payment_success_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';

  // Annotator routes
  static const String annotatorHome = '/annotator';
  static const String annotatorProjectTasks = '/annotator/projects/tasks';
  static const String annotatorChatRoom = '/annotator/chat/room';
  static const String annotatorTaskDetail = '/annotator/tasks/detail';
  static const String annotatorLabeling = '/annotator/tasks/labeling';

  // Reviewer routes
  static const String reviewerHome = '/reviewer';
  static const String reviewerProjectTasks = '/reviewer/projects/tasks';
  static const String reviewerChatRoom = '/reviewer/chat/room';
  static const String reviewerTaskDetail = '/reviewer/tasks/detail';

  // Manager routes
  static const String managerHome = '/manager';
  static const String managerProjectCreate = '/manager/projects/create';
  static const String managerProjectDetail = '/manager/projects/detail';
  static const String managerDatasetUpload = '/manager/datasets/upload';
  static const String managerDatasetDetail = '/manager/datasets/detail';
  static const String managerTaskCreate = '/manager/tasks/create';
  static const String managerUserForm = '/manager/users/form';
  static const String managerPaymentList = '/manager/payments';
  static const String managerPaymentDetail = '/manager/payments/detail';
  static const String managerPaymentHistory = '/manager/payments/history';
  static const String managerPaymentSuccess = '/manager/payments/success';

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
      case verifyEmail:
        final args = settings.arguments;
        if (args is! Map<String, dynamic> || args['email'] is! String) {
          return _errorRoute('Email not provided for verification');
        }
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: args['email'] as String),
        );
      case annotatorHome:
        return MaterialPageRoute(builder: (_) => const AnnotatorShellScreen());
      case annotatorProjectTasks:
        final project = settings.arguments;
        if (project is! MyProjectSummaryModel) {
          return _errorRoute('Project not provided');
        }
        return MaterialPageRoute(
          builder: (_) => AnnotatorProjectTasksScreen(project: project),
        );
      case annotatorChatRoom:
        final project = settings.arguments;
        if (project is! MyProjectSummaryModel) {
          return _errorRoute('Project not provided for chat');
        }
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(project: project),
        );
      case annotatorTaskDetail:
        final taskId = settings.arguments as String?;
        if (taskId == null) {
          return _errorRoute('Task ID not provided');
        }
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        );
      case annotatorLabeling:
        final args = settings.arguments;
        if (args is! Map<String, dynamic> || args['taskId'] is! String) {
          return _errorRoute('Task ID not provided for labeling');
        }
        return MaterialPageRoute(
          builder: (_) => LabelingScreen(
            taskId: args['taskId'] as String,
            readOnly: args['readOnly'] as bool? ?? false,
          ),
        );
      case reviewerHome:
        return MaterialPageRoute(builder: (_) => const ReviewerShellScreen());
      case reviewerProjectTasks:
        final reviewerProject = settings.arguments;
        if (reviewerProject is! MyProjectSummaryModel) {
          return _errorRoute('Project not provided');
        }
        return MaterialPageRoute(
          builder: (_) => ReviewerProjectTasksScreen(project: reviewerProject),
        );
      case reviewerChatRoom:
        final chatProject = settings.arguments;
        if (chatProject is! MyProjectSummaryModel) {
          return _errorRoute('Project not provided for chat');
        }
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(project: chatProject),
        );
      case reviewerTaskDetail:
        final reviewerTaskId = settings.arguments as String?;
        if (reviewerTaskId == null) {
          return _errorRoute('Task ID not provided');
        }
        return MaterialPageRoute(
          builder: (_) => ReviewerTaskDetailScreen(taskId: reviewerTaskId),
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
      case managerUserForm:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => UserFormScreen(userId: userId),
        );

      case managerPaymentList:
        return MaterialPageRoute(builder: (_) => const PaymentListScreen());

      case managerPaymentDetail:
        return MaterialPageRoute(builder: (_) => const PaymentDetailScreen());

      case managerPaymentHistory:
        return MaterialPageRoute(builder: (_) => const PaymentHistoryScreen());

      case managerPaymentSuccess:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args == null) {
          return _errorRoute('Missing payment success data');
        }

        return MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            transactionId: args['transactionId'] ?? '',
            amount: args['amount'] ?? 0,
            name: args['name'] ?? '',
          ),
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
