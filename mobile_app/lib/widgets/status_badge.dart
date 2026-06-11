import 'package:flutter/material.dart';

import 'dlss_badge.dart';

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
    if (!outlined) return DlssBadge.forTaskStatus(status);
    return DlssBadge(label: status, variant: DlssBadgeVariant.outline);
  }
}
