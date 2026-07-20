import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../providers/reviewer_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/annotator/annotator_project_card.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_empty_state.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class ReviewerProjectListScreen extends StatefulWidget {
  const ReviewerProjectListScreen({super.key});

  @override
  State<ReviewerProjectListScreen> createState() =>
      _ReviewerProjectListScreenState();
}

class _ReviewerProjectListScreenState extends State<ReviewerProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewerProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: WorkflowStrings.reviewerProjectsTitle,
                subtitle: WorkflowStrings.reviewerProjectsSubtitle,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DlssCard(
                  variant: DlssCardVariant.glass,
                  fillHeight: true,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: _buildBody(provider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ReviewerProvider provider) {
    if (provider.isProjectsLoading && provider.projects.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.projectsState == ReviewerLoadState.error &&
        provider.projects.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? AppConstants.errorGeneric,
        icon: Icons.error_outline,
        onRetry: provider.fetchProjects,
      );
    }

    if (provider.projects.isEmpty) {
      return const DlssEmptyState(
        icon: Icons.folder_off_outlined,
        message: WorkflowStrings.reviewerNoProjects,
        hint: WorkflowStrings.reviewerNoProjectsHint,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchProjects,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.projects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final project = provider.projects[index];
          return AnnotatorProjectCard(
            project: project,
            showDoneStat: false,
            todoBadgeLabel: '${project.todoTaskCount} pending',
            primaryStatLabel: '${project.todoTaskCount} pending review',
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.reviewerProjectTasks, arguments: project),
          );
        },
      ),
    );
  }
}
