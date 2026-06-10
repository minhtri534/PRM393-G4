import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/task_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/status_badge.dart';
import '../splash_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId})
      : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load task details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().selectTask(widget.taskId);
    });
  }

  @override
  void dispose() {
    context.read<TaskProvider>().clearSelectedTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          // Loading state
          if (taskProvider.isLoading) {
            return const SplashScreen();
          }

          // Error state
          if (taskProvider.state == TaskState.error) {
            return error_widget.ErrorWidget(
              message: taskProvider.errorMessage ??
                  AppConstants.errorGeneric,
              icon: Icons.error_outline,
              onRetry: () {
                taskProvider.selectTask(widget.taskId);
              },
            );
          }

          // No task selected
          if (taskProvider.selectedTask == null) {
            return error_widget.ErrorWidget(
              message: AppConstants.errorTaskNotFound,
              icon: Icons.assignment_outlined,
            );
          }

          final task = taskProvider.selectedTask!;
          final items = taskProvider.taskItems;
          final labels = taskProvider.taskLabels;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(
              AppConstants.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppConstants.paddingMedium,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Task ID',
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    task.id,
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodySmall,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            StatusBadge(
                              status: task.status,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AppConstants
                              .paddingMedium,
                        ),
                        Divider(),
                        const SizedBox(
                          height: AppConstants
                              .paddingSmall,
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Project',
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    task.projectId
                                        .substring(0, 8),
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    'Data Item',
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    task.dataItemId
                                        .substring(0, 8),
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppConstants.paddingLarge,
                ),

                // Task Items Section
                Text(
                  'Data Items (${items.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Text(
                    'No data items',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.image_outlined,
                          ),
                          title: Text(
                            'Item ${index + 1}',
                          ),
                          subtitle: Text(
                            '${item.originalWidth}x${item.originalHeight}',
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .bodySmall,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                const SizedBox(
                  height: AppConstants.paddingLarge,
                ),

                // Labels Section
                Text(
                  'Labels (${labels.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (labels.isEmpty)
                  Text(
                    'No labels',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: labels
                        .map(
                          (label) => Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _parseHexColor(
                                label.color,
                              ).withOpacity(0.15),
                              border: Border.all(
                                color: _parseHexColor(
                                  label.color,
                                ),
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),
                            child: Text(
                              label.name,
                              style: TextStyle(
                                color: _parseHexColor(
                                  label.color,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(
                  height: AppConstants.paddingLarge,
                ),

                // Action Buttons
                if (task.status ==
                    AppConstants.taskStatusAssigned)
                  Column(
                    children: [
                      ActionButton(
                        label: 'Accept Task',
                        onPressed: () async {
                          final success =
                              await taskProvider
                                  .acceptTask(
                            task.id,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Task accepted successfully',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      ActionButton(
                        label: 'Start Task',
                        isOutlined: true,
                        onPressed: () async {
                          final success =
                              await taskProvider
                                  .startTask(
                            task.id,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Task started successfully',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _parseHexColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse('0x$hex'));
    }
    return Colors.grey;
  }
}
