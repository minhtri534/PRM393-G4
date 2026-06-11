import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
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
        if (provider.isLoading && provider.projects.isEmpty) {
          return const LoadingSkeleton(itemCount: 4);
        }

        if (provider.state == ManagerLoadState.error &&
            provider.projects.isEmpty) {
          return error_widget.ErrorWidget(
            message: provider.errorMessage ?? 'Failed to load projects',
            onRetry: () => provider.fetchProjects(),
          );
        }

        if (provider.projects.isEmpty) {
          return const Center(child: Text('No projects yet'));
        }

        return RefreshIndicator(
          onRefresh: provider.fetchProjects,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                            const SnackBar(content: Text('Project archived')),
                          );
                        }
                      },
              );
            },
          ),
        );
      },
    );
  }
}
