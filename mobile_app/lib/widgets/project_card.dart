import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/manager/yolo_label_file_model.dart';
import 'dlss_badge.dart';
import 'dlss_card.dart';

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
    return DlssCard(
      onTap: onTap,
      topAccent: const BorderSide(color: AppTheme.primaryColor, width: 4),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              DlssBadge(
                label: project.isArchived ? 'Archived' : 'Active',
                variant: project.isArchived
                    ? DlssBadgeVariant.secondary
                    : DlssBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            project.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            project.guideline?.trim().isNotEmpty == true
                ? project.guideline!
                : 'No detailed guideline provided.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Created: ${project.createdAt?.toLocal().toString().split(' ').first ?? '-'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
    );
  }
}
