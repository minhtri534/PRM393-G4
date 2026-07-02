import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/chat/chat_models.dart';
import 'dlss_badge.dart';
import 'dlss_card.dart';

class AnnotatorProjectCard extends StatelessWidget {
  final MyProjectSummaryModel project;
  final VoidCallback onTap;
  final bool showChatPreview;
  final bool showDoneStat;
  final String? todoBadgeLabel;
  final String? primaryStatLabel;

  const AnnotatorProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.showChatPreview = false,
    this.showDoneStat = true,
    this.todoBadgeLabel,
    this.primaryStatLabel,
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
                label: todoBadgeLabel ?? '${project.todoTaskCount} to do',
                variant: project.todoTaskCount > 0
                    ? DlssBadgeVariant.primary
                    : DlssBadgeVariant.secondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                : 'No guideline provided for this project.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat(
                Icons.assignment_outlined,
                primaryStatLabel ?? '${project.todoTaskCount} tasks',
              ),
              if (showDoneStat) ...[
                const SizedBox(width: 12),
                _stat(Icons.check_circle_outline, '${project.doneTaskCount} done'),
              ],
            ],
          ),
          if (showChatPreview &&
              project.lastChatMessagePreview?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 14, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    project.lastChatMessagePreview!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
