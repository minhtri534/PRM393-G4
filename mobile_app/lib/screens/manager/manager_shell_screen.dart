import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'dataset_list_screen.dart';
import 'project_list_screen.dart';

class ManagerShellScreen extends StatefulWidget {
  const ManagerShellScreen({super.key});

  @override
  State<ManagerShellScreen> createState() => _ManagerShellScreenState();
}

class _ManagerShellScreenState extends State<ManagerShellScreen> {
  int _index = 0;

  static const _titles = ['Projects', 'Datasets'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const ProjectListScreen(),
      const DatasetListScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (_) => false,
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.manage_accounts,
                      color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Manager',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    context.watch<AuthProvider>().userProfile?.email ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Projects'),
              selected: _index == 0,
              onTap: () {
                setState(() => _index = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Datasets'),
              selected: _index == 1,
              onTap: () {
                setState(() => _index = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            label: 'Datasets',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.managerProjectCreate),
              icon: const Icon(Icons.add),
              label: const Text('New Project'),
            )
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.managerDatasetUpload),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Dataset'),
            ),
    );
  }
}
