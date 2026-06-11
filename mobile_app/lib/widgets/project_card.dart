import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/manager/manager_models.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: project.isArchived
                          ? AppTheme.warningColor.withValues(alpha: 0.15)
                          : AppTheme.successColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.isArchived ? 'Archived' : 'Active',
                      style: TextStyle(
                        color: project.isArchived
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (project.guideline != null &&
                  project.guideline!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  project.guideline!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: ${project.updatedAt?.toLocal().toString().split('.').first ?? '-'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!project.isArchived && onArchive != null)
                    TextButton(
                      onPressed: onArchive,
                      child: const Text('Archive'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
