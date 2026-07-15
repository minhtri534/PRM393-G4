import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/workflow_strings.dart';
import '../core/theme/app_theme.dart';
import '../models/reviewer/reviewer_models.dart';
import 'dlss_badge.dart';
import 'dlss_card.dart';

class ReviewerTaskCard extends StatelessWidget {
  final ReviewerSubmittedTaskModel task;
  final VoidCallback onTap;

  const ReviewerTaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DlssCard(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      onTap: onTap,
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
            label: WorkflowStrings.reviewerPendingBadge,
            variant: DlssBadgeVariant.primary,
          ),
        ],
      ),
    );
  }
}
