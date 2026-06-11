import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

enum DlssBadgeVariant { primary, secondary, success, danger, outline }

class DlssBadge extends StatelessWidget {
  final String label;
  final DlssBadgeVariant variant;

  const DlssBadge({
    super.key,
    required this.label,
    this.variant = DlssBadgeVariant.primary,
  });

  factory DlssBadge.forTaskStatus(String status) {
    switch (status) {
      case AppConstants.taskStatusAssigned:
        return DlssBadge(label: 'Assigned', variant: DlssBadgeVariant.secondary);
      case AppConstants.taskStatusInProgress:
        return const DlssBadge(label: 'In Progress');
      case AppConstants.taskStatusSubmitted:
        return const DlssBadge(label: 'Submitted', variant: DlssBadgeVariant.success);
      case AppConstants.taskStatusApproved:
      case 'Completed':
        return const DlssBadge(label: 'Completed', variant: DlssBadgeVariant.success);
      case AppConstants.taskStatusRejected:
      case 'Returned':
      case 'Rework':
        return const DlssBadge(label: 'Revision Required', variant: DlssBadgeVariant.danger);
      default:
        return DlssBadge(label: status, variant: DlssBadgeVariant.outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late Color border;

    switch (variant) {
      case DlssBadgeVariant.primary:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        border = const Color(0xFFBFDBFE);
      case DlssBadgeVariant.secondary:
        bg = AppTheme.surfaceSoftColor;
        fg = AppTheme.textSecondaryColor;
        border = AppTheme.borderColor;
      case DlssBadgeVariant.success:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        border = const Color(0xFFA7F3D0);
      case DlssBadgeVariant.danger:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        border = const Color(0xFFFECACA);
      case DlssBadgeVariant.outline:
        bg = Colors.transparent;
        fg = AppTheme.textSecondaryColor;
        border = AppTheme.borderColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
