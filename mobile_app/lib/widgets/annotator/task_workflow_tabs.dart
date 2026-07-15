import 'package:flutter/material.dart';

import '../../core/constants/workflow_strings.dart';
import '../../core/theme/app_theme.dart';

class TaskWorkflowTabs extends StatelessWidget {
  final int selectedTab;
  final int todoCount;
  final int doneCount;
  final ValueChanged<int> onChanged;

  const TaskWorkflowTabs({
    super.key,
    required this.selectedTab,
    required this.todoCount,
    required this.doneCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabChip(
            label: WorkflowStrings.todoTabLabel(todoCount),
            selected: selectedTab == 0,
            activeColor: AppTheme.primaryColor,
            onTap: () => onChanged(0),
          ),
          _TabChip(
            label: WorkflowStrings.doneTabLabel(doneCount),
            selected: selectedTab == 1,
            activeColor: AppTheme.successColor,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x11000000), blurRadius: 8)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? activeColor : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
