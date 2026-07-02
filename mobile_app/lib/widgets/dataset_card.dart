import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/manager/dataset_model.dart';
import 'dlss_card.dart';

class DatasetCard extends StatelessWidget {
  final DatasetModel dataset;
  final VoidCallback? onTap;

  const DatasetCard({super.key, required this.dataset, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DlssCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storage_outlined,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataset.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dataset.projectName ?? dataset.projectId} • ${dataset.totalItems ?? 0} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textHintColor),
        ],
      ),
    );
  }
}
