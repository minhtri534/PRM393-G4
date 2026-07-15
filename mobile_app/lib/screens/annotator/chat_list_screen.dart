import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/annotator/annotator_project_card.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: 'Project Chat',
                subtitle: 'Message your project team in real time.',
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

  Widget _buildBody(ChatProvider provider) {
    if (provider.projectsState == ChatLoadState.loading &&
        provider.projects.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.projectsState == ChatLoadState.error &&
        provider.projects.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? AppConstants.errorGeneric,
        icon: Icons.error_outline,
        onRetry: provider.fetchProjects,
      );
    }

    if (provider.projects.isEmpty) {
      return Center(
        child: Text(
          'No project chat rooms available.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),
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
            showChatPreview: true,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.annotatorChatRoom,
              arguments: project,
            ),
          );
        },
      ),
    );
  }
}
