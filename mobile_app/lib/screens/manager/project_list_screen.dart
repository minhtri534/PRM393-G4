import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: AppConstants.managerProjectListTitle,
                subtitle: AppConstants.managerProjectListSubtitle,
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ManagerProvider provider) {
    if (provider.isLoading && provider.projects.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.state == ManagerLoadState.error && provider.projects.isEmpty) {
      return error_widget.ErrorWidget(
        message:
            provider.errorMessage ??
            AppConstants.managerProjectListProjectLoadError,
        onRetry: provider.fetchProjects,
      );
    }

    if (provider.projects.isEmpty) {
      return Center(
        child: Text(
          AppConstants.managerProjectListNoProjects,
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchProjects,
      child: ListView.separated(
        itemCount: provider.projects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final project = provider.projects[index];
          return ProjectCard(
            project: project,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerProjectDetail,
              arguments: project.id,
            ),
            onArchive: project.isArchived
                ? null
                : () async {
                    final ok = await provider.archiveProject(project.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            AppConstants.managerProjectListAlertProjectArchived,
                          ),
                        ),
                      );
                    }
                  },
          );
        },
      ),
    );
  }
}
