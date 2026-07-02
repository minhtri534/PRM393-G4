import 'package:flutter/material.dart';

import '../../widgets/dlss_dashboard_scaffold.dart';
import '../annotator/chat_list_screen.dart';
import 'reviewer_project_list_screen.dart';

class ReviewerShellScreen extends StatelessWidget {
  const ReviewerShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DlssDashboardScaffold(
      roleTitle: 'Reviewer Workspace',
      roleIcon: Icons.fact_check_outlined,
      destinations: [
        DlssNavDestination(
          label: 'Projects',
          icon: Icons.folder_outlined,
          body: ReviewerProjectListScreen(),
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
