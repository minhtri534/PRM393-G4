import 'package:flutter/material.dart';

import '../core/constants/workflow_strings.dart';
import '../core/theme/app_theme.dart';
import '../models/annotator/annotator_models.dart';
import 'dlss_card.dart';

class ReviewFeedbackCard extends StatelessWidget {
  final AnnotatorReviewFeedbackModel feedback;
  final bool compact;

  const ReviewFeedbackCard({
    super.key,
    required this.feedback,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = compact
        ? Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            )
        : Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            );

    return DlssCard(
      padding: compact ? const EdgeInsets.all(14) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.feedback_outlined, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                WorkflowStrings.annotatorReviewFeedback,
                style: titleStyle,
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            compact
                ? 'Result: ${feedback.result} • Score: ${feedback.score}'
                : 'Result: ${feedback.result}',
          ),
          if (!compact) Text('Score: ${feedback.score}'),
          if (feedback.comment?.isNotEmpty == true) ...[
            SizedBox(height: compact ? 6 : 8),
            compact
                ? Text(feedback.comment!)
                : Container(
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
                  .map((error) => Chip(label: Text(error.errorName)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
