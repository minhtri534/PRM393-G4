import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../providers/annotator_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/annotator/annotator_project_card.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_empty_state.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class AnnotatorProjectListScreen extends StatefulWidget {
  const AnnotatorProjectListScreen({super.key});

  @override
  State<AnnotatorProjectListScreen> createState() =>
      _AnnotatorProjectListScreenState();
}

class _AnnotatorProjectListScreenState
    extends State<AnnotatorProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnotatorProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotatorProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: WorkflowStrings.annotatorProjectsTitle,
                subtitle: WorkflowStrings.annotatorProjectsSubtitle,
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

  Widget _buildBody(AnnotatorProvider provider) {
    if (provider.isProjectsLoading && provider.projects.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.projectsState == AnnotatorLoadState.error &&
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
        message: WorkflowStrings.annotatorNoProjects,
        hint: WorkflowStrings.annotatorNoProjectsHint,
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
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.annotatorProjectTasks, arguments: project),
          );
        },
      ),
    );
  }
}
