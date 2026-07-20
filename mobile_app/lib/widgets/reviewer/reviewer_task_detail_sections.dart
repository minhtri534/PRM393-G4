import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/reviewer/reviewer_models.dart';
import '../../providers/reviewer_provider.dart';
import '../action_button.dart';
import '../bbox_labeling_canvas.dart';
import '../dlss_card.dart';

class ReviewerValidationChips extends StatelessWidget {
  final GuidelineComparisonModel? guidelineComparison;
  final LabelConsistencyModel? labelConsistency;

  const ReviewerValidationChips({
    super.key,
    required this.guidelineComparison,
    required this.labelConsistency,
  });

  @override
  Widget build(BuildContext context) {
    final guideline = guidelineComparison;
    final consistency = labelConsistency;

    if (guideline == null && consistency == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (guideline != null)
          _ValidationChip(
            label: guideline.isAligned ? 'Guideline OK' : 'Guideline issues',
            color: guideline.isAligned ? AppTheme.successColor : Colors.red,
          ),
        if (consistency != null)
          _ValidationChip(
            label: consistency.isConsistent
                ? 'Labels consistent'
                : 'Label issues',
            color: consistency.isConsistent
                ? AppTheme.successColor
                : Colors.orange,
          ),
      ],
    );
  }
}

class _ValidationChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ValidationChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class ReviewerValidationNotes extends StatelessWidget {
  final ReviewerProvider provider;

  const ReviewerValidationNotes({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final notes = <String>[
      ...?provider.guidelineComparison?.notes,
      ...?provider.labelConsistency?.issues,
    ];
    if (notes.isEmpty) return const SizedBox.shrink();

    return DlssCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            WorkflowStrings.reviewerValidationInsights,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...notes.map(
            (note) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(note, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewerAnnotationPreview extends StatelessWidget {
  final ReviewerProvider provider;

  const ReviewerAnnotationPreview({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return DlssCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 360,
        child: provider.taskImageBytes == null
            ? const Center(
                child: Text(WorkflowStrings.reviewerImageUnavailable),
              )
            : BboxLabelingCanvas(
                imageBytes: provider.taskImageBytes,
                imageWidth: provider.imageWidth,
                imageHeight: provider.imageHeight,
                boxes: provider.labelingBoxes,
                labels: provider.taskLabels,
                selectedLabelId: null,
                selectedBoxIndex: null,
                drawMode: false,
                readOnly: true,
                onBoxCreated: (_) {},
                onBoxSelected: (_) {},
              ),
      ),
    );
  }
}

class ReviewerReviewActionBar extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onReturn;
  final VoidCallback onApprove;

  const ReviewerReviewActionBar({
    super.key,
    required this.isSubmitting,
    required this.onReturn,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: ActionButton(
                label: WorkflowStrings.reviewerReturn,
                variant: ActionButtonVariant.outline,
                icon: Icons.undo,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : onReturn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                label: WorkflowStrings.reviewerApprove,
                icon: Icons.check_circle_outline,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : onApprove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
