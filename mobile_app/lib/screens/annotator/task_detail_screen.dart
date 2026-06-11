import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/task_display_utils.dart';
import '../../providers/annotator_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/dlss_badge.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/error_widget.dart' as error_widget;

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  AnnotatorProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<AnnotatorProvider>();
      _provider!.loadTaskDetail(widget.taskId);
    });
  }

  @override
  void dispose() {
    _provider?.clearSelectedTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
        title: Consumer<AnnotatorProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.selectedTask?.displayTitle ?? 'Task Details',
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ),
      body: Consumer<AnnotatorProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading && provider.selectedTask == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailState == AnnotatorLoadState.error) {
            return error_widget.ErrorWidget(
              message: provider.errorMessage ?? AppConstants.errorGeneric,
              icon: Icons.error_outline,
              onRetry: () => provider.loadTaskDetail(widget.taskId),
            );
          }

          final task = provider.selectedTask;
          if (task == null) {
            return error_widget.ErrorWidget(
              message: AppConstants.errorTaskNotFound,
              icon: Icons.assignment_outlined,
              onRetry: () => provider.loadTaskDetail(widget.taskId),
            );
          }

          final imageName = provider.taskItems.isNotEmpty
              ? provider.taskItems.first.fileName
              : TaskDisplayUtils.fileNameFromObjectKey(task.dataItemObjectKey);
          final progress = task.status == AppConstants.taskStatusInProgress ? 0.5 : 0.1;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                children: [
                  if (provider.taskImageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        provider.taskImageBytes!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(Icons.image_outlined,
                          size: 48, color: AppTheme.textHintColor),
                    ),
                  const SizedBox(height: 16),
                  DlssCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Task Description',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSoftColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Text(
                            'This task belongs to project ${task.projectName ?? task.projectId}. '
                            'You need to label ${imageName.isNotEmpty ? imageName : 'the data item'} '
                            'according to the project guideline.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DlssCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guidelines',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text(
                            provider.guideline?.trim().isNotEmpty == true
                                ? provider.guideline!
                                : 'No specific guideline for this project.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF1E3A8A),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DlssCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Labels',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (provider.taskLabels.isEmpty)
                          Text(
                            'No labels configured',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.taskLabels
                                .map(
                                  (label) => Chip(
                                    label: Text(
                                      '${label.name} (${label.yoloClassId})',
                                    ),
                                    backgroundColor: Color(
                                      int.parse(
                                        'FF${label.colorHex.replaceAll('#', '')}',
                                        radix: 16,
                                      ),
                                    ).withValues(alpha: 0.12),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DlssCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textHintColor,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DlssBadge.forTaskStatus(task.status),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF3F4F6),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Progress: ${(progress * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
              if (task.status == AppConstants.taskStatusAssigned)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: DlssCard(
                    child: Column(
                      children: [
                        ActionButton(
                          label: 'Accept Task',
                          icon: Icons.check_circle_outline,
                          onPressed: () => provider.acceptTask(task.id),
                        ),
                        const SizedBox(height: 8),
                        ActionButton(
                          label: 'Start Labeling',
                          icon: Icons.play_circle_outline,
                          isOutlined: true,
                          onPressed: () => provider.startTask(task.id),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
