import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.status,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case AppConstants.taskStatusAssigned:
        color = AppTheme.warningColor;
        icon = Icons.assignment;
        break;
      case AppConstants.taskStatusInProgress:
        color = AppTheme.infoColor;
        icon = Icons.pending_actions;
        break;
      case AppConstants.taskStatusSubmitted:
        color = AppTheme.warningColor;
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.taskStatusApproved:
        color = AppTheme.successColor;
        icon = Icons.verified;
        break;
      case AppConstants.taskStatusRejected:
        color = AppTheme.errorColor;
        icon = Icons.cancel;
        break;
      default:
        color = AppTheme.textHintColor;
        icon = Icons.help_outline;
    }

    if (outlined) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: color),
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color),
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }
  }
}
