import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/annotator/annotator_models.dart';
import '../../providers/annotator_provider.dart';
import '../action_button.dart';
import '../dlss_badge.dart';
import '../dlss_card.dart';
import '../label_chip_row.dart';
import '../review_feedback_card.dart';
import 'annotator_task_preview_image.dart';

class AnnotatorTaskDetailContent extends StatelessWidget {
  final AnnotatorProvider provider;
  final AnnotatorTaskModel task;
  final String imageName;
  final bool showActions;

  const AnnotatorTaskDetailContent({
    super.key,
    required this.provider,
    required this.task,
    required this.imageName,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    final progress = provider.selectedTaskProgress;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        AnnotatorTaskPreviewImage(imageBytes: provider.taskImageBytes),
        const SizedBox(height: 16),
        if (provider.reviewFeedback != null) ...[
          ReviewFeedbackCard(feedback: provider.reviewFeedback!),
          const SizedBox(height: 16),
        ],
        DlssCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    WorkflowStrings.annotatorTaskDescription,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                WorkflowStrings.annotatorGuidelines,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      : WorkflowStrings.annotatorNoGuideline,
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
                WorkflowStrings.annotatorLabels,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              LabelChipRow(labels: provider.taskLabels),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DlssCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WorkflowStrings.annotatorStatus,
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
    );
  }
}

class AnnotatorTaskActionBar extends StatelessWidget {
  final AnnotatorTaskModel task;
  final VoidCallback onAccept;
  final VoidCallback onStartLabeling;
  final VoidCallback onReject;
  final VoidCallback onContinueLabeling;
  final VoidCallback onViewLabeling;
  final VoidCallback onOpenChat;

  const AnnotatorTaskActionBar({
    super.key,
    required this.task,
    required this.onAccept,
    required this.onStartLabeling,
    required this.onReject,
    required this.onContinueLabeling,
    required this.onViewLabeling,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final canLabel = annotatorTaskCanLabel(task.status);
    final isAssigned = task.status == AppConstants.taskStatusAssigned;
    final isSubmitted = task.status == AppConstants.taskStatusSubmitted ||
        task.status == AppConstants.taskStatusCompleted ||
        task.status == AppConstants.taskStatusApproved;

    return DlssCard(
      child: Column(
        children: [
          if (isAssigned) ...[
            ActionButton(
              label: WorkflowStrings.annotatorAcceptTask,
              icon: Icons.check_circle_outline,
              onPressed: onAccept,
            ),
            const SizedBox(height: 8),
            ActionButton(
              label: WorkflowStrings.annotatorStartLabeling,
              icon: Icons.play_circle_outline,
              variant: ActionButtonVariant.gradient,
              onPressed: onStartLabeling,
            ),
            const SizedBox(height: 8),
            ActionButton(
              label: WorkflowStrings.annotatorRejectTask,
              icon: Icons.cancel_outlined,
              variant: ActionButtonVariant.outline,
              onPressed: onReject,
            ),
          ] else if (canLabel) ...[
            ActionButton(
              label: annotatorLabelingButtonLabel(task.status),
              icon: Icons.edit_outlined,
              variant: ActionButtonVariant.gradient,
              onPressed: onContinueLabeling,
            ),
          ] else if (isSubmitted) ...[
            ActionButton(
              label: WorkflowStrings.annotatorViewLabeling,
              icon: Icons.visibility_outlined,
              variant: ActionButtonVariant.outline,
              onPressed: onViewLabeling,
            ),
          ],
          const SizedBox(height: 8),
          ActionButton(
            label: WorkflowStrings.annotatorChatWithTeam,
            icon: Icons.chat_bubble_outline,
            variant: ActionButtonVariant.outline,
            onPressed: onOpenChat,
          ),
        ],
      ),
    );
  }
}
