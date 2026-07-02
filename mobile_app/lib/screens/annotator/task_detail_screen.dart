import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/task_display_utils.dart';
import '../../models/annotator/annotator_models.dart';
import '../../models/chat/chat_models.dart';
import '../../providers/annotator_provider.dart';
import '../../routes/app_routes.dart';
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

  Future<void> _openLabeling(
    BuildContext context, {
    required bool readOnly,
  }) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.annotatorLabeling,
      arguments: {
        'taskId': widget.taskId,
        'readOnly': readOnly,
      },
    );
    if (!mounted) return;
    if (result == true) {
      final provider = context.read<AnnotatorProvider>();
      await provider.fetchTasks(projectId: provider.selectedProjectId);
    }
    await context.read<AnnotatorProvider>().loadTaskDetail(widget.taskId);
  }

  Future<void> _startLabeling(AnnotatorProvider provider) async {
    final started = await provider.startTask(widget.taskId);
    if (!started || !mounted) return;
    await _openLabeling(context, readOnly: false);
  }

  String _labelingButtonLabel(String status) {
    if (status == 'Returned' ||
        status == AppConstants.taskStatusRejected ||
        status == 'Rework') {
      return 'Revise Labeling';
    }
    return 'Continue Labeling';
  }

  Future<void> _rejectTask(AnnotatorProvider provider) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject task?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Why are you rejecting this task?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      reasonController.dispose();
      return;
    }

    final ok = await provider.rejectTask(
      widget.taskId,
      reason: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );
    reasonController.dispose();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Task rejected' : provider.errorMessage ?? 'Failed')),
    );
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  Widget _reviewFeedbackCard(
    BuildContext context,
    AnnotatorReviewFeedbackModel feedback,
  ) {
    return DlssCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.feedback_outlined, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'Review Feedback',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Result: ${feedback.result}'),
          Text('Score: ${feedback.score}'),
          if (feedback.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.25),
                ),
              ),
              child: Text(feedback.comment!),
            ),
          ],
          if (feedback.errorCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: feedback.errorCategories
                  .map((e) => Chip(label: Text(e.errorName)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBar(BuildContext context, AnnotatorProvider provider, AnnotatorTaskModel task) {
    final canLabel = annotatorTaskCanLabel(task.status);
    final isAssigned = task.status == AppConstants.taskStatusAssigned;
    final isSubmitted = task.status == AppConstants.taskStatusSubmitted ||
        task.status == 'Completed' ||
        task.status == AppConstants.taskStatusApproved;

    return DlssCard(
      child: Column(
        children: [
          if (isAssigned) ...[
            ActionButton(
              label: 'Accept Task',
              icon: Icons.check_circle_outline,
              onPressed: () async {
                final ok = await provider.acceptTask(task.id);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task accepted')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            ActionButton(
              label: 'Start Labeling',
              icon: Icons.play_circle_outline,
              variant: ActionButtonVariant.gradient,
              onPressed: () => _startLabeling(provider),
            ),
            const SizedBox(height: 8),
            ActionButton(
              label: 'Reject Task',
              icon: Icons.cancel_outlined,
              variant: ActionButtonVariant.outline,
              onPressed: () => _rejectTask(provider),
            ),
          ] else if (canLabel) ...[
            ActionButton(
              label: _labelingButtonLabel(task.status),
              icon: Icons.edit_outlined,
              variant: ActionButtonVariant.gradient,
              onPressed: () => _openLabeling(context, readOnly: false),
            ),
          ] else if (isSubmitted) ...[
            ActionButton(
              label: 'View Labeling',
              icon: Icons.visibility_outlined,
              variant: ActionButtonVariant.outline,
              onPressed: () => _openLabeling(context, readOnly: true),
            ),
          ],
          const SizedBox(height: 8),
          ActionButton(
            label: 'Chat with project team',
            icon: Icons.chat_bubble_outline,
            variant: ActionButtonVariant.outline,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.annotatorChatRoom,
                arguments: MyProjectSummaryModel(
                  id: task.projectId,
                  name: task.projectName ?? 'Project',
                  todoTaskCount: 0,
                  doneTaskCount: 0,
                ),
              );
            },
          ),
        ],
      ),
    );
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
          final progress = provider.selectedTaskProgress;
          final showActions = task.status == AppConstants.taskStatusAssigned ||
              annotatorTaskCanLabel(task.status) ||
              task.status == AppConstants.taskStatusSubmitted ||
              task.status == 'Completed';

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
                  if (provider.reviewFeedback != null) ...[
                    _reviewFeedbackCard(context, provider.reviewFeedback!),
                    const SizedBox(height: 16),
                  ],
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
                          'Progress: ${(progress * 100).round()}%'
                          '${provider.annotationCount > 0 ? ' • ${provider.annotationCount} annotation(s)' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: showActions ? 120 : 24),
                ],
              ),
              if (showActions)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _actionBar(context, provider, task),
                ),
            ],
          );
        },
      ),
    );
  }
}
