import 'package:flutter/material.dart';

import '../../widgets/dlss_dashboard_scaffold.dart';
import 'chat_list_screen.dart';
import 'project_list_screen.dart';

class AnnotatorShellScreen extends StatelessWidget {
  const AnnotatorShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DlssDashboardScaffold(
      roleTitle: 'Annotator Workspace',
      roleIcon: Icons.assignment_outlined,
      destinations: [
        DlssNavDestination(
          label: 'Projects',
          icon: Icons.folder_outlined,
          body: AnnotatorProjectListScreen(),
        ),
        DlssNavDestination(
          label: 'Chat',
          icon: Icons.chat_bubble_outline,
          body: ChatListScreen(),
        ),
      ],
    );
  }
}
