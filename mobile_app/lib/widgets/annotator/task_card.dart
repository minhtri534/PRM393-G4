import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/annotator/annotator_models.dart';
import '../dlss_badge.dart';
import '../dlss_card.dart';

class TaskCard extends StatelessWidget {
  final AnnotatorTaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onStart;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onStart,
  });

  bool get _isDone =>
      task.status == AppConstants.taskStatusSubmitted ||
      task.status == AppConstants.taskStatusCompleted ||
      task.status == AppConstants.taskStatusApproved;

  @override
  Widget build(BuildContext context) {
    final iconColor = _isDone ? AppTheme.successColor : AppTheme.primaryColor;
    final iconBg = _isDone ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF);

    return DlssCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment_outlined, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.displaySubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppTheme.textHintColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _isDone
                              ? 'Finished: ${task.completedAt?.toLocal().toString().split('.').first ?? '-'}'
                              : 'Assigned: ${task.assignedAt?.toLocal().toString().split('.').first ?? '-'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.textHintColor,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              DlssBadge.forTaskStatus(task.status),
              const SizedBox(height: 8),
              if (_isDone)
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 20,
                )
              else
                TextButton(
                  onPressed: onStart ?? onTap,
                  child: const Text('Start'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
