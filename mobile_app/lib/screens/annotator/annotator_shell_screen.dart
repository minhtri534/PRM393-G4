import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../widgets/dlss_dashboard_scaffold.dart';
import 'task_list_screen.dart';

class AnnotatorShellScreen extends StatelessWidget {
  const AnnotatorShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DlssDashboardScaffold(
      roleTitle: 'Annotator',
      roleIcon: Icons.assignment_outlined,
      destinations: [
        DlssNavDestination(
          label: 'My Tasks',
          icon: Icons.assignment_outlined,
          body: TaskListScreen(),
        ),
      ],
    );
  }
}
