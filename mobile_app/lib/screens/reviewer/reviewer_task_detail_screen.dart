import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/reviewer_provider.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/reviewer/reviewer_task_detail_sections.dart';

class ReviewerTaskDetailScreen extends StatefulWidget {
  final String taskId;

  const ReviewerTaskDetailScreen({super.key, required this.taskId});

  @override
  State<ReviewerTaskDetailScreen> createState() =>
      _ReviewerTaskDetailScreenState();
}

class _ReviewerTaskDetailScreenState extends State<ReviewerTaskDetailScreen> {
  final _commentController = TextEditingController();
  final Set<String> _selectedErrorTypeIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReviewerProvider>();
      provider.loadReviewDetail(widget.taskId);
      provider.loadErrorTypes();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _approve(ReviewerProvider provider) async {
    final ok = await provider.approveTask(
      widget.taskId,
      score: 100,
      comment: _commentController.text.trim().isEmpty
          ? 'Approved'
          : _commentController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WorkflowStrings.reviewerApproved)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Approve failed')),
      );
    }
  }

  Future<void> _returnTask(ReviewerProvider provider) async {
    final feedback = _commentController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WorkflowStrings.reviewerFeedbackRequired)),
      );
      return;
    }

    final ok = await provider.returnTask(
      widget.taskId,
      feedback: feedback,
      score: 0,
      errorTypeIds: _selectedErrorTypeIds.isEmpty
          ? null
          : _selectedErrorTypeIds.toList(),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WorkflowStrings.reviewerReturned)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Return failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: Text(
          'Review #${widget.taskId.length > 6 ? widget.taskId.substring(widget.taskId.length - 6) : widget.taskId}',
        ),
      ),
      body: Consumer<ReviewerProvider>(
        builder: (context, provider, _) {
          if (provider.isDetailLoading && provider.labeledData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailState == ReviewerLoadState.error &&
              provider.labeledData == null) {
            return error_widget.ErrorWidget(
              message: provider.errorMessage ?? AppConstants.errorGeneric,
              icon: Icons.error_outline,
              onRetry: () => provider.loadReviewDetail(widget.taskId),
            );
          }

          final data = provider.labeledData;
          if (data == null) {
            return const Center(
              child: Text(WorkflowStrings.reviewerNoLabeledData),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReviewerValidationChips(
                        guidelineComparison: provider.guidelineComparison,
                        labelConsistency: provider.labelConsistency,
                      ),
                      const SizedBox(height: 12),
                      ReviewerAnnotationPreview(provider: provider),
                      const SizedBox(height: 12),
                      ReviewerValidationNotes(provider: provider),
                      if (data.guideline?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        DlssCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                WorkflowStrings.reviewerProjectGuideline,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(data.guideline!),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      DlssCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${WorkflowStrings.reviewerAnnotations} (${data.annotations.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...data.annotations.map(
                              (annotation) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${annotation.labelName} (${annotation.annotationType})',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (provider.errorTypes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DlssCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                WorkflowStrings.reviewerErrorTypes,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: provider.errorTypes.map((type) {
                                  final selected =
                                      _selectedErrorTypeIds.contains(type.id);
                                  return FilterChip(
                                    label: Text(type.name),
                                    selected: selected,
                                    onSelected: (value) {
                                      setState(() {
                                        if (value) {
                                          _selectedErrorTypeIds.add(type.id);
                                        } else {
                                          _selectedErrorTypeIds.remove(type.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: WorkflowStrings.reviewerCommentLabel,
                          hintText: WorkflowStrings.reviewerCommentHint,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              ReviewerReviewActionBar(
                isSubmitting: provider.isSubmitting,
                onReturn: () => _returnTask(provider),
                onApprove: () => _approve(provider),
              ),
            ],
          );
        },
      ),
    );
  }
}
