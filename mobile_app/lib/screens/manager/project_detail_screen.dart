import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/manager_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../models/manager/manager_models.dart';
import '../../providers/manager_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dataset_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _guidelineController = TextEditingController();
  final _datasetNameController = TextEditingController();
  final _labelNameController = TextEditingController();
  final _labelClassController = TextEditingController(text: '0');
  final _categoryNameController = TextEditingController();
  final _annotationTypeController = TextEditingController();
  final _userSearchController = TextEditingController();
  final _projectNameController = TextEditingController();
  final Set<String> _selectedTaskIds = {};
  int? _projectStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ManagerProvider>();
      provider.loadProjectDetail(widget.projectId);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final provider = context.read<ManagerProvider>();
    switch (_tabController.index) {
      case 2:
        provider.loadProjectTasks(widget.projectId);
      case 3:
        provider.loadMonitoring(widget.projectId);
      case 4:
        provider.loadExports(widget.projectId);
      default:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _guidelineController.dispose();
    _datasetNameController.dispose();
    _labelNameController.dispose();
    _labelClassController.dispose();
    _categoryNameController.dispose();
    _annotationTypeController.dispose();
    _userSearchController.dispose();
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _showTaskHistory(ManagerProvider provider, String taskId) async {
    final history = await provider.getTaskHistory(taskId);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Task History', style: Theme.of(ctx).textTheme.titleMedium),
          if (history.isEmpty)
            const ListTile(title: Text('No history'))
          else
            ...history.map(
              (h) => ListTile(
                title: Text('${h.oldStatus ?? '-'} → ${h.newStatus ?? '-'}'),
                subtitle: Text(
                  '${h.changedByUserId} • ${h.changedAt?.toLocal()}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showRelabelDialog(
    ManagerProvider provider,
    String taskId,
  ) async {
    final reasonController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Relabel'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (ok == true && reasonController.text.trim().isNotEmpty) {
      await provider.requestRelabeling(taskId, reasonController.text.trim());
    }
    reasonController.dispose();
  }

  Future<void> _showBulkAssignDialog(ManagerProvider provider) async {
    if (_selectedTaskIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select tasks first')),
      );
      return;
    }
    String? annotatorId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Bulk assign ${_selectedTaskIds.length} tasks'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Annotator',
              border: OutlineInputBorder(),
            ),
            items: provider.annotators
                .map(
                  (a) => DropdownMenuItem(
                    value: a.userId,
                    child: Text(a.userEmail),
                  ),
                )
                .toList(),
            onChanged: (v) => setDialogState(() => annotatorId = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, annotatorId != null),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && annotatorId != null) {
      final success = await provider.bulkAssignTasks(
        taskIds: _selectedTaskIds.toList(),
        annotatorId: annotatorId!,
      );
      if (success && mounted) {
        setState(() => _selectedTaskIds.clear());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        final project = provider.selectedProject;
        if (provider.isLoading && project == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(provider.errorMessage ?? 'Project not found')),
          );
        }

        if (_guidelineController.text.isEmpty &&
            (project.guideline?.isNotEmpty ?? false)) {
          _guidelineController.text = project.guideline!;
        }
        if (_projectNameController.text.isEmpty) {
          _projectNameController.text = project.name;
        }
        _projectStatus ??= project.status;

        return Scaffold(
          appBar: AppBar(
            title: Text(project.name),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Data'),
                Tab(text: 'Tasks'),
                Tab(text: 'Monitor'),
                Tab(text: 'Exports'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _overviewTab(provider, project),
              _dataTab(provider),
              _tasksTab(provider),
              _monitoringTab(provider),
              _exportsTab(provider),
              _settingsTab(provider),
            ],
          ),
          floatingActionButton: ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) {
              if (_tabController.index != 2) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerTaskCreate,
                  arguments: widget.projectId,
                ),
                icon: const Icon(Icons.add_task),
                label: const Text('Create Tasks'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _overviewTab(ManagerProvider provider, ProjectModel project) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        Text('Guideline', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _guidelineController,
          label: 'Project Guideline',
          hintText: 'Instructions for annotators',
        ),
        const SizedBox(height: 12),
        ActionButton(
          label: 'Save Guideline',
          isLoading: provider.isLoading,
          onPressed: () => provider.updateGuideline(
            widget.projectId,
            _guidelineController.text.trim(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Team Members', style: Theme.of(context).textTheme.titleMedium),
        ...provider.projectRoles.map(
          (role) => ListTile(
            title: Text(role.userEmail),
            subtitle: Text(role.roleName),
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _userSearchController,
          label: 'Search user to assign',
          hintText: 'Type name or email',
          onChanged: (v) => provider.searchUsers(v),
        ),
        ...provider.userSearchResults.map(
          (user) => ListTile(
            title: Text(user.fullName),
            subtitle: Text(user.email),
            trailing: PopupMenuButton<String>(
              onSelected: (roleId) => provider.assignProjectRole(
                projectId: widget.projectId,
                userId: user.id,
                roleId: roleId,
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: ManagerRoleIds.annotator,
                  child: Text('Assign as Annotator'),
                ),
                const PopupMenuItem(
                  value: ManagerRoleIds.reviewer,
                  child: Text('Assign as Reviewer'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dataTab(ManagerProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        Text('Datasets', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _datasetNameController,
                label: 'New dataset name',
                hintText: 'Dataset name',
              ),
            ),
            IconButton(
              onPressed: () async {
                if (_datasetNameController.text.trim().isEmpty) return;
                final ok = await provider.createDataset(
                  projectId: widget.projectId,
                  name: _datasetNameController.text.trim(),
                );
                if (ok) _datasetNameController.clear();
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        ...provider.datasets.map(
          (d) => DatasetCard(
            dataset: d,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerDatasetDetail,
              arguments: d.id,
            ),
          ),
        ),
        const Divider(height: 32),
        Text('Labels', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _labelNameController,
                label: 'Label name',
                hintText: 'e.g. Car',
              ),
            ),
            SizedBox(
              width: 80,
              child: CustomTextField(
                controller: _labelClassController,
                label: 'YOLO ID',
                hintText: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              onPressed: () async {
                final classId = int.tryParse(_labelClassController.text) ?? 0;
                await provider.createLabel(
                  projectId: widget.projectId,
                  name: _labelNameController.text.trim(),
                  yoloClassId: classId,
                );
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...provider.labels.map(
          (l) => ListTile(
            title: Text(l.name),
            subtitle: Text('YOLO class ${l.yoloClassId}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteLabel(l.id),
            ),
            onTap: () async {
              final nameController = TextEditingController(text: l.name);
              final classController =
                  TextEditingController(text: '${l.yoloClassId}');
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Edit Label'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextField(
                        controller: classController,
                        decoration: const InputDecoration(labelText: 'YOLO ID'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await provider.updateLabel(
                  l.id,
                  name: nameController.text.trim(),
                  yoloClassId: int.tryParse(classController.text) ?? 0,
                );
              }
              nameController.dispose();
              classController.dispose();
            },
          ),
        ),
        const Divider(height: 32),
        Text('Categories', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _categoryNameController,
                label: 'Category name',
                hintText: 'Category',
              ),
            ),
            IconButton(
              onPressed: () => provider.createLabelCategory(
                projectId: widget.projectId,
                name: _categoryNameController.text.trim(),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...provider.labelCategories.map(
          (c) => ListTile(
            title: Text(c.name),
            subtitle: Text(c.description ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteLabelCategory(c.id),
            ),
          ),
        ),
        const Divider(height: 32),
        Text('Annotation Types', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _annotationTypeController,
                label: 'Type name',
                hintText: 'Bounding box',
              ),
            ),
            IconButton(
              onPressed: () => provider.createAnnotationType(
                projectId: widget.projectId,
                name: _annotationTypeController.text.trim(),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...provider.annotationTypes.map(
          (t) => ListTile(
            title: Text(t.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteAnnotationType(t.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tasksTab(ManagerProvider provider) {
    final progress = provider.taskProgress;
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        if (progress != null)
          Row(
            children: [
              _statTile('Total', '${progress.total}'),
              _statTile('Assigned', '${progress.assigned}'),
              _statTile('In Progress', '${progress.inProgress}'),
            ],
          ),
        if (progress != null) const SizedBox(height: 8),
        if (progress != null)
          Row(
            children: [
              _statTile('Submitted', '${progress.submitted}'),
              _statTile('Completed', '${progress.completed}'),
              _statTile('Rework', '${progress.rework}'),
            ],
          ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _showBulkAssignDialog(provider),
              icon: const Icon(Icons.group_add),
              label: Text('Bulk assign (${_selectedTaskIds.length})'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...provider.projectTasks.map((task) {
          final selected = _selectedTaskIds.contains(task.id);
          return Card(
            child: ListTile(
              leading: Checkbox(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _selectedTaskIds.add(task.id);
                    } else {
                      _selectedTaskIds.remove(task.id);
                    }
                  });
                },
              ),
              title: Text('Task ${task.id.substring(0, 8)}...'),
              subtitle: Text('Status: ${task.status}'),
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'pause') {
                    await provider.pauseTask(task.id);
                  } else if (action == 'resume') {
                    await provider.resumeTask(task.id);
                  } else if (action == 'cancel') {
                    await provider.cancelTask(task.id);
                  } else if (action == 'history') {
                    await _showTaskHistory(provider, task.id);
                  } else if (action == 'relabel') {
                    await _showRelabelDialog(provider, task.id);
                  } else if (action == 'yolo') {
                    final result = await provider.exportYoloTask(task.id);
                    if (result != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'YOLO export: ${result.classes.length} classes, ${result.files.length} files',
                          ),
                        ),
                      );
                    }
                  } else if (action.startsWith('assign:')) {
                    await provider.assignTask(
                      task.id,
                      action.split(':').last,
                    );
                  } else if (action.startsWith('reassign:')) {
                    await provider.reassignTask(
                      task.id,
                      action.split(':').last,
                    );
                  }
                },
                itemBuilder: (_) => [
                  ...provider.annotators.map(
                    (a) => PopupMenuItem(
                      value: 'assign:${a.userId}',
                      child: Text('Assign ${a.userEmail}'),
                    ),
                  ),
                  ...provider.annotators.map(
                    (a) => PopupMenuItem(
                      value: 'reassign:${a.userId}',
                      child: Text('Reassign ${a.userEmail}'),
                    ),
                  ),
                  const PopupMenuItem(value: 'pause', child: Text('Pause')),
                  const PopupMenuItem(value: 'resume', child: Text('Resume')),
                  const PopupMenuItem(value: 'relabel', child: Text('Relabel')),
                  const PopupMenuItem(value: 'history', child: Text('History')),
                  const PopupMenuItem(value: 'yolo', child: Text('YOLO Export')),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _monitoringTab(ManagerProvider provider) {
    final report = provider.qualityReport;
    if (report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        Card(
          child: ListTile(
            title: const Text('Completion'),
            subtitle: Text(
              '${report.progress.completedTasks}/${report.progress.totalTasks} tasks completed',
            ),
            trailing: Text(
              report.progress.totalTasks == 0
                  ? '0%'
                  : '${((report.progress.completedTasks / report.progress.totalTasks) * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Review Stats'),
            subtitle: Text(
              'Approved: ${report.reviewStats.approvedReviews} • Rejected: ${report.reviewStats.rejectedReviews}',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('Inconsistent Labels'),
            trailing: Text('${report.inconsistentLabelsCount}'),
          ),
        ),
        const SizedBox(height: 16),
        Text('Annotator Performance',
            style: Theme.of(context).textTheme.titleMedium),
        ...provider.annotatorPerformance.map(
          (a) => ListTile(
            title: Text(a.annotatorEmail),
            subtitle: Text(
              'Assigned ${a.assignedTasks} • Submitted ${a.submittedTasks} • Done ${a.completedTasks}',
            ),
          ),
        ),
        if (provider.inconsistentLabels.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Issues', style: Theme.of(context).textTheme.titleMedium),
          ...provider.inconsistentLabels.map(
            (i) => ListTile(
              title: Text(i.issue),
              subtitle: Text('Task ${i.taskId}'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _exportsTab(ManagerProvider provider) {
    final validation = provider.exportValidation;
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      children: [
        if (validation != null)
          Card(
            color: validation.isValid
                ? AppTheme.successColor.withValues(alpha: 0.1)
                : AppTheme.warningColor.withValues(alpha: 0.1),
            child: ListTile(
              title: Text(validation.isValid ? 'Ready to export' : 'Not ready'),
              subtitle: Text(
                'Submitted: ${validation.submittedAnnotationSets} • Reviewed: ${validation.reviewedAnnotationSets}',
              ),
            ),
          ),
        ActionButton(
          label: 'Create YOLO Export',
          isLoading: provider.isLoading,
          onPressed: () => provider.createExport(projectId: widget.projectId),
        ),
        const SizedBox(height: 16),
        Text('Export History', style: Theme.of(context).textTheme.titleMedium),
        ...provider.exports.map(
          (e) => ListTile(
            title: Text('${e.format} • ${e.createdAt?.toLocal()}'),
            subtitle: Text(e.exportedByEmail ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final bytes =
                    await provider.downloadExport(e.id);
                if (bytes != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloaded ${bytes.length} bytes'),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const Divider(height: 32),
        Text('Activity Log', style: Theme.of(context).textTheme.titleMedium),
        ...provider.activityLogs.map(
          (log) => ListTile(
            title: Text(log.action),
            subtitle: Text(
              '${log.userEmail ?? log.userId} • ${log.createdAt?.toLocal()}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsTab(ManagerProvider provider) {
    final project = provider.selectedProject;
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _projectNameController,
            label: 'Project Name',
            hintText: 'Project name',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _projectStatus ?? project?.status ?? 0,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Active')),
              DropdownMenuItem(value: 1, child: Text('Paused')),
              DropdownMenuItem(value: 9, child: Text('Archived')),
            ],
            onChanged: (status) {
              if (status != null) setState(() => _projectStatus = status);
            },
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Save Project',
            isLoading: provider.isLoading,
            onPressed: () async {
              if (project == null) return;
              await provider.updateProject(
                projectId: widget.projectId,
                name: _projectNameController.text.trim(),
                guideline: project.guideline,
                status: _projectStatus ?? project.status,
              );
            },
          ),
          const SizedBox(height: 24),
          ActionButton(
            label: 'Archive Project',
            isOutlined: true,
            onPressed: () async {
              final ok = await provider.archiveProject(widget.projectId);
              if (ok && context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: 'Delete Project',
            isOutlined: true,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete project?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final ok = await provider.deleteProject(widget.projectId);
                if (ok && context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
