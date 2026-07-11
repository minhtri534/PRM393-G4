import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_dashboard_scaffold.dart';
import 'dataset_list_screen.dart';
import 'project_list_screen.dart';
import 'user_list_screen.dart';

class ManagerShellScreen extends StatelessWidget {
  const ManagerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DlssDashboardScaffold(
      roleTitle: 'Manager',
      roleIcon: Icons.manage_accounts_outlined,
      destinations: const [
        DlssNavDestination(
          label: 'Projects',
          icon: Icons.folder_outlined,
          body: ProjectListScreen(),
        ),
        DlssNavDestination(
          label: 'Datasets',
          icon: Icons.storage_outlined,
          body: DatasetListScreen(),
        ),
        DlssNavDestination(
          label: 'Users',
          icon: Icons.people_outline,
          body: UserListScreen(),
        ),
      ],
      fabBuilder: (index) {
        if (index == 0) {
          return FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.managerProjectCreate,
              );
              if (context.mounted) {
                await context.read<ManagerProvider>().fetchProjects();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('New Project'),
          );
        }
        if (index == 1) {
          return FloatingActionButton.extended(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.managerDatasetUpload),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Dataset'),
          );
        }
        return FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.managerUserForm);
            if (context.mounted) {
              await context.read<ManagerProvider>().fetchUsers();
            }
          },
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('New User'),
        );
      },
    );
  }
}
