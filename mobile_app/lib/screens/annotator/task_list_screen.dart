import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          // Loading state
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const LoadingSkeleton(itemCount: 5);
          }

          // Error state
          if (taskProvider.state == TaskState.error &&
              taskProvider.tasks.isEmpty) {
            return error_widget.ErrorWidget(
              message: taskProvider.errorMessage ??
                  AppConstants.errorGeneric,
              icon: Icons.error_outline,
              onRetry: () {
                taskProvider.fetchTasks();
              },
            );
          }

          // Empty state
          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks assigned',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new tasks',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      taskProvider.fetchTasks();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          // Loaded state - list of tasks
          return RefreshIndicator(
            onRefresh: () async {
              await taskProvider.fetchTasks();
            },
            child: ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/task-detail',
                      arguments: task.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout().then((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
