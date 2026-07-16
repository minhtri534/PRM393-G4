import 'package:flutter/material.dart';

import '../../core/constants/workflow_strings.dart';
import '../../core/utils/label_color_utils.dart';
import '../../models/annotator/annotator_models.dart';

class LabelChipRow extends StatelessWidget {
  final List<AnnotatorLabelModel> labels;
  final String? selectedLabelId;
  final bool editable;
  final ValueChanged<String>? onLabelSelected;

  const LabelChipRow({
    super.key,
    required this.labels,
    this.selectedLabelId,
    this.editable = false,
    this.onLabelSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return Text(
        editable
            ? WorkflowStrings.annotatorNoProjectLabels
            : WorkflowStrings.annotatorNoLabels,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (editable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: labels.map((label) {
            final selected = selectedLabelId == label.id;
            final color = LabelColorUtils.fromHex(label.colorHex);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label.name),
                selected: selected,
                selectedColor: color.withValues(alpha: 0.2),
                onSelected: onLabelSelected == null
                    ? null
                    : (_) => onLabelSelected!(label.id),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((label) {
        final color = LabelColorUtils.fromHex(label.colorHex);
        return Chip(
          label: Text(label.name),
          backgroundColor: color.withValues(alpha: 0.12),
        );
      }).toList(),
    );
  }
}
