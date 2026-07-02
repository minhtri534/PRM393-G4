import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/reviewer_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/bbox_labeling_canvas.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/error_widget.dart' as error_widget;

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
        const SnackBar(content: Text('Task approved successfully')),
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
        const SnackBar(
          content: Text('Please provide feedback before returning'),
        ),
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
        const SnackBar(content: Text('Task returned with feedback')),
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
            return const Center(child: Text('No labeled data available'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _validationChips(provider),
                      const SizedBox(height: 12),
                      DlssCard(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 360,
                          child: provider.taskImageBytes == null
                              ? const Center(child: Text('Image not available'))
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
                      ),
                      const SizedBox(height: 12),
                      _validationNotes(provider),
                      if (data.guideline?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 12),
                        DlssCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Project Guideline',
                                style: Theme.of(context).textTheme.titleSmall
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
                              'Annotations (${data.annotations.length})',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...data.annotations.map(
                              (ann) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• ${ann.labelName} (${ann.annotationType})',
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
                                'Error types (optional)',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: provider.errorTypes.map((type) {
                                  final selected = _selectedErrorTypeIds
                                      .contains(type.id);
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
                          labelText: 'Comment / feedback',
                          hintText: 'Required when returning a task',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _actionBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _validationChips(ReviewerProvider provider) {
    final guideline = provider.guidelineComparison;
    final consistency = provider.labelConsistency;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (guideline != null)
          _chip(
            guideline.isAligned ? 'Guideline OK' : 'Guideline issues',
            guideline.isAligned ? AppTheme.successColor : Colors.red,
          ),
        if (consistency != null)
          _chip(
            consistency.isConsistent ? 'Labels consistent' : 'Label issues',
            consistency.isConsistent ? AppTheme.successColor : Colors.orange,
          ),
      ],
    );
  }

  Widget _chip(String label, Color color) {
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

  Widget _validationNotes(ReviewerProvider provider) {
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
            'Validation insights',
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

  Widget _actionBar(ReviewerProvider provider) {
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
                label: 'Return',
                variant: ActionButtonVariant.outline,
                icon: Icons.undo,
                isLoading: provider.isSubmitting,
                onPressed: provider.isSubmitting
                    ? null
                    : () => _returnTask(provider),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                label: 'Approve',
                icon: Icons.check_circle_outline,
                isLoading: provider.isSubmitting,
                onPressed: provider.isSubmitting
                    ? null
                    : () => _approve(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
