import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/annotator/annotator_task.dart';

class TaskCard extends StatelessWidget {
  final AnnotatorTask task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task: ${task.id.substring(0, 8)}...',
                          style:
                              Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Project: ${task.projectId.substring(0, 8)}...',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Divider(
                color: AppTheme.borderColor,
                height: 1,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (task.assignedAt != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            _formatDate(task.assignedAt!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  if (task.completedAt != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Completed',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            _formatDate(task.completedAt!),
                            style: Theme.of(context).textTheme.bodySmall,
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
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    IconData icon;

    switch (task.status) {
      case AppConstants.taskStatusAssigned:
        badgeColor = AppTheme.warningColor;
        icon = Icons.assignment;
        break;
      case AppConstants.taskStatusInProgress:
        badgeColor = AppTheme.infoColor;
        icon = Icons.pending_actions;
        break;
      case AppConstants.taskStatusSubmitted:
        badgeColor = AppTheme.warningColor;
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.taskStatusApproved:
        badgeColor = AppTheme.successColor;
        icon = Icons.verified;
        break;
      case AppConstants.taskStatusRejected:
        badgeColor = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        badgeColor = AppTheme.textHintColor;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            task.status,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
