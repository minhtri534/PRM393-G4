import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/manager/manager_models.dart';

class DatasetCard extends StatelessWidget {
  final DatasetModel dataset;
  final VoidCallback? onTap;

  const DatasetCard({
    super.key,
    required this.dataset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(dataset.name),
        subtitle: Text(
          '${dataset.projectName ?? dataset.projectId} • ${dataset.totalItems ?? 0} items',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
