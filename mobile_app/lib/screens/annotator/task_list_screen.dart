import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/annotator_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnotatorProvider>().fetchTasks();
    });
  }

  bool _isTodo(String status) => [
        AppConstants.taskStatusAssigned,
        AppConstants.taskStatusInProgress,
        'Returned',
        'Rejected',
        'Rework',
      ].contains(status);

  bool _isDone(String status) => [
        AppConstants.taskStatusSubmitted,
        'Completed',
        AppConstants.taskStatusApproved,
      ].contains(status);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotatorProvider>(
      builder: (context, provider, _) {
        final todoCount = provider.tasks.where((t) => _isTodo(t.status)).length;
        final doneCount = provider.tasks.where((t) => _isDone(t.status)).length;
        final filtered = provider.tasks.where((t) {
          return _tab == 0 ? _isTodo(t.status) : _isDone(t.status);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DlssPageHeader(
                title: 'Workspace',
                subtitle: 'View assigned tasks and track annotation progress.',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _SegmentedTabs(
                  tab: _tab,
                  todoCount: todoCount,
                  doneCount: doneCount,
                  onChanged: (v) => setState(() => _tab = v),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DlssCard(
                  variant: DlssCardVariant.glass,
                  fillHeight: true,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: _buildBody(provider, filtered),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AnnotatorProvider provider, List filtered) {
    if (provider.isListLoading && provider.tasks.isEmpty) {
      return const LoadingSkeleton(itemCount: 4);
    }

    if (provider.listState == AnnotatorLoadState.error &&
        provider.tasks.isEmpty) {
      return error_widget.ErrorWidget(
        message: provider.errorMessage ?? AppConstants.errorGeneric,
        icon: Icons.error_outline,
        onRetry: provider.fetchTasks,
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _tab == 0
                  ? 'You have no tasks to do.'
                  : "You haven't completed any tasks yet.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchTasks,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = filtered[index];
          return TaskCard(
            task: task,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.annotatorTaskDetail,
              arguments: task.id,
            ),
            onStart: () async {
              final provider = context.read<AnnotatorProvider>();
              await provider.startTask(task.id);
              if (!context.mounted) return;
              final result = await Navigator.of(context).pushNamed(
                AppRoutes.annotatorLabeling,
                arguments: {'taskId': task.id, 'readOnly': false},
              );
              if (result == true && context.mounted) {
                provider.fetchTasks();
              }
            },
          );
        },
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int tab;
  final int todoCount;
  final int doneCount;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.tab,
    required this.todoCount,
    required this.doneCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip('To Do ($todoCount)', 0, AppTheme.primaryColor),
          _chip('Done ($doneCount)', 1, AppTheme.successColor),
        ],
      ),
    );
  }

  Widget _chip(String label, int value, Color activeColor) {
    final selected = tab == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x11000000), blurRadius: 8)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? activeColor : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }
}
