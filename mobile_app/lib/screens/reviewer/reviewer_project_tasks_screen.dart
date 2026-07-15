import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../models/chat/chat_models.dart';
import '../../providers/reviewer_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_empty_state.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/reviewer_task_card.dart';

class ReviewerProjectTasksScreen extends StatefulWidget {
  final MyProjectSummaryModel project;

  const ReviewerProjectTasksScreen({super.key, required this.project});

  @override
  State<ReviewerProjectTasksScreen> createState() =>
      _ReviewerProjectTasksScreenState();
}

class _ReviewerProjectTasksScreenState extends State<ReviewerProjectTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ReviewerProvider>()
          .fetchSubmittedTasks(projectId: widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            tooltip: 'Project chat',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.reviewerChatRoom,
              arguments: widget.project,
            ),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
        ],
      ),
      body: Consumer<ReviewerProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DlssPageHeader(
                  title: WorkflowStrings.reviewerPendingReview,
                  subtitle: widget.project.guideline?.trim().isNotEmpty == true
                      ? widget.project.guideline!
                      : WorkflowStrings.reviewerPendingReviewSubtitle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DlssCard(
                    variant: DlssCardVariant.glass,
                    fillHeight: true,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: _TaskListBody(
                      provider: provider,
                      projectId: widget.project.id,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskListBody extends StatelessWidget {
  final ReviewerProvider provider;
  final String projectId;

  const _TaskListBody({
    required this.provider,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isListLoading && provider.tasks.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.listState == ReviewerLoadState.error && provider.tasks.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? AppConstants.errorGeneric,
        icon: Icons.error_outline,
        onRetry: () => provider.fetchSubmittedTasks(projectId: projectId),
      );
    }

    if (provider.tasks.isEmpty) {
      return const DlssEmptyState(
        icon: Icons.inbox_outlined,
        message: WorkflowStrings.reviewerNoPendingTasks,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchSubmittedTasks(projectId: projectId),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return ReviewerTaskCard(
            task: task,
            onTap: () => _openTaskDetail(context, task.id),
          );
        },
      ),
    );
  }

  Future<void> _openTaskDetail(BuildContext context, String taskId) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.reviewerTaskDetail,
      arguments: taskId,
    );
    if (result == true && context.mounted) {
      context.read<ReviewerProvider>().fetchSubmittedTasks(projectId: projectId);
    }
  }
}
