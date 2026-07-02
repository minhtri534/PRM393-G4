import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PaymentStatusChip extends StatelessWidget {
  final String status;

  const PaymentStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        background = Colors.green.shade100;
        foreground = Colors.green.shade700;
        icon = Icons.check_circle;
        break;

      case 'pending':
        background = Colors.orange.shade100;
        foreground = Colors.orange.shade700;
        icon = Icons.schedule;
        break;

      case 'failed':
        background = Colors.red.shade100;
        foreground = Colors.red.shade700;
        icon = Icons.error;
        break;

      default:
        background = AppTheme.borderColor;
        foreground = Colors.black87;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}