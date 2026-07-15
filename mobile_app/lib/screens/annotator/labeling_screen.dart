import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/annotator_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/bbox_labeling_canvas.dart';
import '../../widgets/annotator/label_chip_row.dart';
import '../../widgets/annotator/review_feedback_card.dart';
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
        content: Text(
          ok ? WorkflowStrings.annotatorDraftSaved : provider.errorMessage ?? 'Save failed',
        ),
      ),
    );
  }

  Future<void> _submit(AnnotatorProvider provider) async {
    final ok = await provider.submitLabeling(widget.taskId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(WorkflowStrings.annotatorSubmitted)),
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
        title: const Text(WorkflowStrings.annotatorLabelingTitle),
        actions: [
          if (editable)
            IconButton(
              tooltip: _drawMode ? 'Select mode' : 'Draw mode',
              onPressed: () => setState(() => _drawMode = !_drawMode),
              icon: Icon(
                _drawMode ? Icons.pan_tool_alt_outlined : Icons.crop_free,
              ),
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
              icon: Icons.error_outline,
              onRetry: () => provider.loadLabelingSession(widget.taskId),
            );
          }

          return Column(
            children: [
              if (provider.reviewFeedback != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ReviewFeedbackCard(
                    feedback: provider.reviewFeedback!,
                    compact: true,
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
                    labels: provider.taskLabels,
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
                      WorkflowStrings.annotatorLabels,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    LabelChipRow(
                      labels: provider.taskLabels,
                      selectedLabelId: provider.selectedLabelId,
                      editable: editable,
                      onLabelSelected: provider.selectLabel,
                    ),
                    const SizedBox(height: 12),
                    if (editable && provider.selectedBoxIndex != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: provider.removeSelectedBox,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text(
                            WorkflowStrings.annotatorDeleteSelectedBox,
                          ),
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
                        label: provider.isSaving
                            ? 'Saving...'
                            : WorkflowStrings.annotatorSaveDraft,
                        variant: ActionButtonVariant.outline,
                        isLoading: provider.isSaving,
                        onPressed: provider.isSaving
                            ? null
                            : () => _saveDraft(provider),
                      ),
                      const SizedBox(height: 10),
                      ActionButton(
                        label: provider.isSaving
                            ? 'Submitting...'
                            : WorkflowStrings.annotatorSubmit,
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
