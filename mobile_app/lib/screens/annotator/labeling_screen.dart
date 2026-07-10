import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/annotator_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/bbox_labeling_canvas.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/error_widget.dart' as error_widget;

class LabelingScreen extends StatefulWidget {
  final String taskId;
  final bool readOnly;

  const LabelingScreen({
    super.key,
    required this.taskId,
    this.readOnly = false,
  });

  @override
  State<LabelingScreen> createState() => _LabelingScreenState();
}

class _LabelingScreenState extends State<LabelingScreen> {
  bool _drawMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnnotatorProvider>().loadLabelingSession(widget.taskId);
    });
  }

  int _imageWidth(AnnotatorProvider provider) {
    if (provider.taskItems.isNotEmpty &&
        provider.taskItems.first.originalWidth > 0) {
      return provider.taskItems.first.originalWidth;
    }
    return 800;
  }

  int _imageHeight(AnnotatorProvider provider) {
    if (provider.taskItems.isNotEmpty &&
        provider.taskItems.first.originalHeight > 0) {
      return provider.taskItems.first.originalHeight;
    }
    return 600;
  }

  Future<void> _saveDraft(AnnotatorProvider provider) async {
    final ok = await provider.saveDraft(widget.taskId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Draft saved' : provider.errorMessage ?? 'Save failed'),
      ),
    );
  }

  Future<void> _submit(AnnotatorProvider provider) async {
    final ok = await provider.submitLabeling(widget.taskId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task submitted successfully')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Submit failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editable = !widget.readOnly;

    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: const Text('Labeling'),
        actions: [
          if (editable)
            IconButton(
              tooltip: _drawMode ? 'Select mode' : 'Draw mode',
              onPressed: () => setState(() => _drawMode = !_drawMode),
              icon: Icon(_drawMode ? Icons.pan_tool_alt_outlined : Icons.crop_free),
            ),
        ],
      ),
      body: Consumer<AnnotatorProvider>(
        builder: (context, provider, _) {
          if (provider.isLabelingLoading && provider.taskImageBytes == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.labelingState == AnnotatorLoadState.error) {
            return error_widget.ErrorWidget(
              message: provider.errorMessage ?? AppConstants.errorGeneric,
              onRetry: () => provider.loadLabelingSession(widget.taskId),
            );
          }

          final feedback = provider.reviewFeedback;
          final labels = provider.taskLabels;

          return Column(
            children: [
              if (feedback != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: DlssCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.feedback_outlined,
                                color: AppTheme.warningColor),
                            const SizedBox(width: 8),
                            Text(
                              'Review feedback',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Result: ${feedback.result} • Score: ${feedback.score}'),
                        if (feedback.comment?.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text(feedback.comment!),
                        ],
                        if (feedback.errorCategories.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: feedback.errorCategories
                                .map((e) => Chip(label: Text(e.errorName)))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BboxLabelingCanvas(
                    imageBytes: provider.taskImageBytes,
                    imageWidth: _imageWidth(provider),
                    imageHeight: _imageHeight(provider),
                    boxes: provider.labelingBoxes,
                    labels: labels,
                    selectedLabelId: provider.selectedLabelId,
                    selectedBoxIndex: provider.selectedBoxIndex,
                    drawMode: _drawMode,
                    readOnly: !editable,
                    onBoxCreated: provider.addLabelingBox,
                    onBoxSelected: (index) =>
                        provider.selectBox(index >= 0 ? index : null),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Labels',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    if (labels.isEmpty)
                      const Text('No labels configured for this project.')
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: labels.map((label) {
                            final selected = provider.selectedLabelId == label.id;
                            final color = Color(
                              int.parse(
                                'FF${label.colorHex.replaceAll('#', '')}',
                                radix: 16,
                              ),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label.name),
                                selected: selected,
                                selectedColor: color.withValues(alpha: 0.2),
                                onSelected: editable
                                    ? (_) => provider.selectLabel(label.id)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (editable && provider.selectedBoxIndex != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: provider.removeSelectedBox,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete selected box'),
                        ),
                      ),
                  ],
                ),
              ),
              if (editable)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ActionButton(
                        label: provider.isSaving ? 'Saving...' : 'Save Draft',
                        variant: ActionButtonVariant.outline,
                        isLoading: provider.isSaving,
                        onPressed: provider.isSaving
                            ? null
                            : () => _saveDraft(provider),
                      ),
                      const SizedBox(height: 10),
                      ActionButton(
                        label: provider.isSaving ? 'Submitting...' : 'Submit',
                        variant: ActionButtonVariant.gradient,
                        isLoading: provider.isSaving,
                        onPressed: provider.isSaving
                            ? null
                            : () => _submit(provider),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
