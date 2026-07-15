import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/workflow_strings.dart';
import '../../core/utils/annotator_task_filters.dart';
import '../../models/annotator/annotator_models.dart';
import '../../providers/annotator_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_empty_state.dart';
import '../../widgets/dlss_page_header.dart';
import '../../widgets/error_widget.dart' as error_widget;
import '../../widgets/loading_skeleton.dart';
import '../../widgets/annotator/task_card.dart';
import '../../widgets/annotator/task_workflow_tabs.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnotatorProvider>(
      builder: (context, provider, _) {
        final todoCount = AnnotatorTaskFilters.countTodo(provider.tasks);
        final doneCount = AnnotatorTaskFilters.countDone(provider.tasks);
        final filtered = AnnotatorTaskFilters.filterByTab(
          provider.tasks,
          showTodo: _tab == 0,
        );

        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DlssPageHeader(
                title: WorkflowStrings.annotatorWorkspaceTitle,
                subtitle: WorkflowStrings.annotatorWorkspaceSubtitle,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TaskWorkflowTabs(
                  selectedTab: _tab,
                  todoCount: todoCount,
                  doneCount: doneCount,
                  onChanged: (value) => setState(() => _tab = value),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DlssCard(
                  variant: DlssCardVariant.glass,
                  fillHeight: true,
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: _TaskListBody(
                    provider: provider,
                    filteredTasks: filtered,
                    showTodoTab: _tab == 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskListBody extends StatelessWidget {
  final AnnotatorProvider provider;
  final List<AnnotatorTaskModel> filteredTasks;
  final bool showTodoTab;

  const _TaskListBody({
    required this.provider,
    required this.filteredTasks,
    required this.showTodoTab,
  });

  @override
  Widget build(BuildContext context) {
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

    if (filteredTasks.isEmpty) {
      return DlssEmptyState(
        icon: Icons.inbox_outlined,
        message: showTodoTab
            ? WorkflowStrings.annotatorNoTodoTasks
            : WorkflowStrings.annotatorNoDoneTasks,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchTasks,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredTasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.annotatorTaskDetail,
              arguments: task.id,
            ),
            onStart: () => _startLabeling(context, task),
          );
        },
      ),
    );
  }

  Future<void> _startLabeling(
    BuildContext context,
    AnnotatorTaskModel task,
  ) async {
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
  }
}
