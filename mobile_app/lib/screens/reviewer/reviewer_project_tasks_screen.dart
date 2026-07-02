import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat/chat_models.dart';
import '../../providers/reviewer_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_badge.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class ReviewerProjectTasksScreen extends StatefulWidget {
  final MyProjectSummaryModel project;

  const ReviewerProjectTasksScreen({super.key, required this.project});

  @override
  State<ReviewerProjectTasksScreen> createState() =>
      _ReviewerProjectTasksScreenState();
}

class _ReviewerProjectTasksScreenState
    extends State<ReviewerProjectTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewerProvider>().fetchSubmittedTasks(
        projectId: widget.project.id,
      );
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
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.reviewerChatRoom, arguments: widget.project),
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
                  title: 'Pending Review',
                  subtitle: widget.project.guideline?.trim().isNotEmpty == true
                      ? widget.project.guideline!
                      : 'Submitted tasks waiting for your review.',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DlssCard(
                    variant: DlssCardVariant.glass,
                    fillHeight: true,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: _buildBody(provider),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ReviewerProvider provider) {
    if (provider.isListLoading && provider.tasks.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.listState == ReviewerLoadState.error &&
        provider.tasks.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? AppConstants.errorGeneric,
        icon: Icons.error_outline,
        onRetry: () =>
            provider.fetchSubmittedTasks(projectId: widget.project.id),
      );
    }

    if (provider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No tasks pending review.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.fetchSubmittedTasks(projectId: widget.project.id),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return DlssCard(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            onTap: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.reviewerTaskDetail, arguments: task.id);
              if (result == true && context.mounted) {
                provider.fetchSubmittedTasks(projectId: widget.project.id);
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rate_review_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.displayTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.displaySubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Submitted: ${task.submittedAt.toLocal().toString().split('.').first}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHintColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const DlssBadge(
                  label: 'Submitted',
                  variant: DlssBadgeVariant.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
