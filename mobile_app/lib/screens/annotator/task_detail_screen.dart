import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/task_display_utils.dart';
import '../../models/annotator/annotator_models.dart';
import '../../models/chat/chat_models.dart';
import '../../providers/annotator_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/annotator/annotator_task_detail_sections.dart';
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

  Future<void> _openLabeling({required bool readOnly}) async {
    final navigator = Navigator.of(context);
    final result = await navigator.pushNamed(
      AppRoutes.annotatorLabeling,
      arguments: {'taskId': widget.taskId, 'readOnly': readOnly},
    );
    if (!mounted) return;

    final provider = context.read<AnnotatorProvider>();
    if (result == true) {
      await provider.fetchTasks(projectId: provider.selectedProjectId);
    }
    await provider.loadTaskDetail(widget.taskId);
  }

  Future<void> _startLabeling() async {
    final provider = context.read<AnnotatorProvider>();
    final started = await provider.startTask(widget.taskId);
    if (!started || !mounted) return;
    await _openLabeling(readOnly: false);
  }

  Future<void> _rejectTask() async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(WorkflowStrings.annotatorRejectDialogTitle),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: WorkflowStrings.annotatorRejectReasonLabel,
            hintText: WorkflowStrings.annotatorRejectReasonHint,
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

    final provider = context.read<AnnotatorProvider>();
    final ok = await provider.rejectTask(
      widget.taskId,
      reason: reasonController.text.trim().isEmpty
          ? null
          : reasonController.text.trim(),
    );
    reasonController.dispose();

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? WorkflowStrings.annotatorTaskRejected
              : provider.errorMessage ?? 'Failed',
        ),
      ),
    );
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _acceptTask() async {
    final provider = context.read<AnnotatorProvider>();
    final ok = await provider.acceptTask(widget.taskId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WorkflowStrings.annotatorTaskAccepted)),
      );
    }
  }

  void _openProjectChat(AnnotatorTaskModel task) {
    Navigator.of(context).pushNamed(
      AppRoutes.annotatorChatRoom,
      arguments: MyProjectSummaryModel(
        id: task.projectId,
        name: task.projectName ?? 'Project',
        todoTaskCount: 0,
        doneTaskCount: 0,
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
              provider.selectedTask?.displayTitle ??
                  WorkflowStrings.annotatorTaskDetails,
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
          final showActions =
              task.status == AppConstants.taskStatusAssigned ||
              annotatorTaskCanLabel(task.status) ||
              task.status == AppConstants.taskStatusSubmitted ||
              task.status == AppConstants.taskStatusCompleted;

          return Stack(
            children: [
              AnnotatorTaskDetailContent(
                provider: provider,
                task: task,
                imageName: imageName,
                showActions: showActions,
              ),
              if (showActions)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: AnnotatorTaskActionBar(
                    task: task,
                    onAccept: _acceptTask,
                    onStartLabeling: _startLabeling,
                    onReject: _rejectTask,
                    onContinueLabeling: () => _openLabeling(readOnly: false),
                    onViewLabeling: () => _openLabeling(readOnly: true),
                    onOpenChat: () => _openProjectChat(task),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
