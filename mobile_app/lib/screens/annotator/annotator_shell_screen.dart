import 'package:flutter/material.dart';

import '../../widgets/dlss_dashboard_scaffold.dart';
import 'task_list_screen.dart';

class AnnotatorShellScreen extends StatelessWidget {
  const AnnotatorShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DlssDashboardScaffold(
      roleTitle: 'Annotator Workspace',
      roleIcon: Icons.assignment_outlined,
      destinations: [
        DlssNavDestination(
          label: 'Workspace',
          icon: Icons.assignment_outlined,
          body: TaskListScreen(),
        ),
      ],
    );
  }
}
