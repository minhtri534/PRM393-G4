import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/manager_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../models/manager/export_model.dart';
import '../../models/manager/project_model.dart';
import '../../providers/manager_provider.dart';
import '../../models/chat/chat_models.dart';
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
  final _userSearchController = TextEditingController();
  final _projectNameController = TextEditingController();
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
          Text(AppConstants.managerProjectDetailTasksTaskHistory, style: Theme.of(ctx).textTheme.titleMedium),
          if (history.isEmpty)
            const ListTile(title: Text(AppConstants.managerProjectDetailTasksNoHistory))
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
        title: const Text(AppConstants.managerProjectDetailTasksRequestRelabel),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: AppConstants.managerProjectDetailTasksRelabelReason,
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppConstants.managerProjectDetailTasksRelabelCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppConstants.managerProjectDetailTasksRelabelSubmit),
          ),
        ],
      ),
    );
    if (ok == true && reasonController.text.trim().isNotEmpty) {
      await provider.requestRelabeling(taskId, reasonController.text.trim());
    }
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        final project = provider.selectedProject;
        if (provider.isLoading && project == null) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceSoftColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (project == null) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceSoftColor,
            appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
            body: Center(
              child: Text(provider.errorMessage ?? AppConstants.managerProjectDetailErrorProjectNotFound),
            ),
          );
        }

        if (project.guideline?.isNotEmpty ?? false) {
          _guidelineController.text = project.guideline!;
        } else {
          _guidelineController.text = '';
        }

        _projectNameController.text = project.name;

        _projectStatus = project.status;

        return Scaffold(
          backgroundColor: AppTheme.surfaceSoftColor,
          appBar: AppBar(
            title: Text(project.name),
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                tooltip: AppConstants.managerProjectDetailProjectChat,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.annotatorChatRoom,
                  arguments: MyProjectSummaryModel(
                    id: project.id,
                    name: project.name,
                    guideline: project.guideline,
                    todoTaskCount: 0,
                    doneTaskCount: 0,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              tabs: const [
                Tab(text: AppConstants.managerProjectDetailTabOverview),
                Tab(text: AppConstants.managerProjectDetailTabData),
                Tab(text: AppConstants.managerProjectDetailTabTasks),
                Tab(text: AppConstants.managerProjectDetailTabMonitor),
                Tab(text: AppConstants.managerProjectDetailTabExports),
                Tab(text: AppConstants.managerProjectDetailTabSettings),
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
                label: const Text(AppConstants.managerProjectDetailTasksCreateTasks),
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
        Text(AppConstants.managerProjectDetailOverviewGuidelines, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _guidelineController,
          label: AppConstants.managerProjectDetailOverviewProjectGuidelines,
          hintText: AppConstants.managerProjectDetailOverviewGuidelinesHint,
        ),
        const SizedBox(height: 12),
        ActionButton(
          label: AppConstants.managerProjectDetailOverviewSaveGuideline,
          isLoading: provider.isLoading,
          onPressed: () => provider.updateGuideline(
            widget.projectId,
            _guidelineController.text.trim(),
          ),
        ),
        const SizedBox(height: 24),
        Text(AppConstants.managerProjectDetailOverviewTeamMembers, style: Theme.of(context).textTheme.titleMedium),
        ...provider.projectRoles.map(
          (role) => ListTile(
            title: Text(role.userEmail),
            subtitle: Text(role.roleName),
            trailing: TextButton(
              onPressed: () =>
                  provider.removeProjectRole(role.projectId, role.userId),
              child: Text(AppConstants.managerProjectDetailOverviewRemove),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _userSearchController,
          label: AppConstants.managerProjectDetailOverviewSearch,
          hintText: AppConstants.managerProjectDetailOverviewSearchHint,
          onChanged: (v) => provider.searchUsers(v),
        ),
        ...provider.userSearchResults.map(
          (user) => ListTile(
            title: Text(user.fullName),
            subtitle: Text(user.email),
            trailing: TextButton(
              onPressed: () => provider.assignProjectRole(
                projectId: widget.projectId,
                userId: user.id,
                roleId: ManagerRoleIds.annotator, //default dummy value
              ),
              child: const Text(AppConstants.managerProjectDetailOverviewAssign),
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
        Text(AppConstants.managerProjectDetailDataDataSet, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _datasetNameController,
                label: AppConstants.managerProjectDetailDataNewDataSet,
                hintText: AppConstants.managerProjectDetailDataDataSetName,
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
        Text(AppConstants.managerProjectDetailDataLabels, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _labelNameController,
                label: AppConstants.managerProjectDetailDataLabelName,
                hintText: AppConstants.managerProjectDetailDataLabelNameHint,
              ),
            ),
            IconButton(
              onPressed: () async {
                final name = _labelNameController.text.trim();
                if (name.isEmpty) return;
                final ok = await provider.createLabel(
                  projectId: widget.projectId,
                  name: name,
                );
                if (ok) _labelNameController.clear();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        ...([
          ...provider.labels,
        ]..sort((a, b) => a.yoloClassId.compareTo(b.yoloClassId))).map(
          (l) => ListTile(
            title: Text(l.name),
            subtitle: Text('${AppConstants.managerProjectDetailDataID} ${l.yoloClassId}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => provider.deleteLabel(l.id),
            ),
            onTap: () async {
              final nameController = TextEditingController(text: l.name);
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(AppConstants.managerProjectDetailDataEditLabel),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: AppConstants.managerProjectDetailDataEditLabelName),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(AppConstants.managerProjectDetailDataEditLabelCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(AppConstants.managerProjectDetailDataEditLabelSave),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await provider.updateLabel(
                  l.id,
                  name: nameController.text.trim(),
                );
              }
              nameController.dispose();
            },
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
              _statTile(AppConstants.managerProjectDetailTasksTotal, '${progress.total}'),
              _statTile(AppConstants.managerProjectDetailTasksAssigned, '${progress.assigned}'),
              _statTile(AppConstants.managerProjectDetailTasksInProgress, '${progress.inProgress}'),
            ],
          ),
        if (progress != null) const SizedBox(height: 8),
        if (progress != null)
          Row(
            children: [
              _statTile(AppConstants.managerProjectDetailTasksSubmitted, '${progress.submitted}'),
              _statTile(AppConstants.managerProjectDetailTasksCompleted, '${progress.completed}'),
              _statTile(AppConstants.managerProjectDetailTasksRework, '${progress.rework}'),
            ],
          ),
        const SizedBox(height: 8),
        ...provider.projectTasks.map((task) {
          return Card(
            child: ListTile(
              title: Text(task.displayTitle),
              subtitle: Text(
                [
                  if (task.datasetName != null) task.datasetName!,
                  if (task.annotatorEmail != null) task.annotatorEmail!,
                  task.status,
                ].join(' • '),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == AppConstants.managerProjectDetailTasksActionPause) {
                    await provider.pauseTask(task.id);
                  } else if (action == AppConstants.managerProjectDetailTasksActionResume) {
                    await provider.resumeTask(task.id);
                  } else if (action == AppConstants.managerProjectDetailTasksActionCancel) {
                    await provider.cancelTask(task.id);
                  } else if (action == AppConstants.managerProjectDetailTasksActionHistory) {
                    await _showTaskHistory(provider, task.id);
                  } else if (action == AppConstants.managerProjectDetailTasksActionRelabel) {
                    await _showRelabelDialog(provider, task.id);
                  } else if (action.startsWith('${AppConstants.managerProjectDetailTasksActionAssign}:')) {
                    await provider.assignTask(task.id, action.split(':').last);
                  } else if (action.startsWith('${AppConstants.managerProjectDetailTasksActionReassign}:')) {
                    await provider.reassignTask(task.id, action.split(':').last,
                    );
                  }
                },
                itemBuilder: (_) => [
                  ...provider.annotators.map(
                    (a) => PopupMenuItem(
                      value: '${AppConstants.managerProjectDetailTasksActionAssign}:${a.userId}',
                      child: Text('${AppConstants.managerProjectDetailTasksActionAssign} ${a.userEmail}'),
                    ),
                  ),
                  ...provider.annotators.map(
                    (a) => PopupMenuItem(
                      value: '${AppConstants.managerProjectDetailTasksActionReassign}:${a.userId}',
                      child: Text('${AppConstants.managerProjectDetailTasksActionReassign} ${a.userEmail}'),
                    ),
                  ),
                  const PopupMenuItem(value: AppConstants.managerProjectDetailTasksActionPause, child: Text(AppConstants.managerProjectDetailTasksActionPause)),
                  const PopupMenuItem(value: AppConstants.managerProjectDetailTasksActionResume, child: Text(AppConstants.managerProjectDetailTasksActionResume)),
                  const PopupMenuItem(value: AppConstants.managerProjectDetailTasksActionRelabel, child: Text(AppConstants.managerProjectDetailTasksActionRelabel)),
                  const PopupMenuItem(value: AppConstants.managerProjectDetailTasksActionHistory, child: Text(AppConstants.managerProjectDetailTasksActionHistory)),
                  const PopupMenuItem(value: AppConstants.managerProjectDetailTasksActionCancel, child: Text(AppConstants.managerProjectDetailTasksActionCancel)),
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
            title: const Text(AppConstants.managerProjectDetailMonitorCompletion),
            subtitle: Text(
              '${report.progress.completedTasks}/${report.progress.totalTasks} ${AppConstants.managerProjectDetailMonitorTasksCompleted}',
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
            title: const Text(AppConstants.managerProjectDetailMonitorReviewStats),
            subtitle: Text(
              '${AppConstants.managerProjectDetailMonitorApproved}: ${report.reviewStats.approvedReviews} • ${AppConstants.managerProjectDetailMonitorRejected}: ${report.reviewStats.rejectedReviews}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.managerProjectDetailMonitorAnnotatorPerformance,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ...provider.annotatorPerformance.map(
          (a) => ListTile(
            title: Text(a.annotatorEmail),
            subtitle: Text(
              '${AppConstants.managerProjectDetailMonitorAssigned} ${a.assignedTasks} • ${AppConstants.managerProjectDetailMonitorSubmitted} ${a.submittedTasks} • ${AppConstants.managerProjectDetailMonitorDone} ${a.completedTasks}',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadExport(
    ManagerProvider provider,
    ExportModel export,
  ) async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.managerProjectDetailExportWebDownloadWarning)),
      );
      return;
    }

    final bytes = await provider.downloadExport(export.id);
    if (!mounted) return;

    if (bytes == null) {
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final isZip = export.format.toUpperCase() == 'YOLO';
      final fileName = 'dlss-export-${export.id}${isZip ? '.zip' : '.json'}';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.managerProjectDetailExportOpenedExport(isZip ? 'ZIP' : 'JSON'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${AppConstants.managerProjectDetailExportOpenError}: $e')));
    }
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
              title: Text(validation.isValid ? AppConstants.managerProjectDetailExportReady : AppConstants.managerProjectDetailExportNotReady),
              subtitle: Text(
                validation.isValid
                    ? AppConstants.managerProjectDetailExportAllReviewed
                    : AppConstants.managerProjectDetailExportSubmittedReviewedCount(validation.submittedAnnotationSets, validation.reviewedAnnotationSets) +
                          AppConstants.managerProjectDetailExportExportWarning,
              ),
            ),
          ),
        Text(
          AppConstants.managerProjectDetailExportInfo,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 12),
        ActionButton(
          label: AppConstants.managerProjectDetailExportCreateExport,
          isLoading: provider.isLoading,
          onPressed: () async {
            final ok = await provider.createExport(projectId: widget.projectId);
            if (!context.mounted) return;
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    AppConstants.managerProjectDetailExportExportCreated,
                  ),
                ),
              );
            } else if (provider.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
            }
          },
        ),
        const SizedBox(height: 16),
        Text(AppConstants.managerProjectDetailExportHistory, style: Theme.of(context).textTheme.titleMedium),
        if (provider.exports.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              AppConstants.managerProjectDetailExportNoExports,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ...provider.exports.map(
          (e) => ListTile(
            title: Text('${e.format} • ${e.createdAt?.toLocal()}'),
            subtitle: Text(e.exportedByEmail ?? ''),
            trailing: IconButton(
              tooltip: AppConstants.managerProjectDetailExportDownload,
              icon: const Icon(Icons.download),
              onPressed: () => _downloadExport(provider, e),
            ),
          ),
        ),
        const Divider(height: 32),
        Text(AppConstants.managerProjectDetailExportActivityLog, style: Theme.of(context).textTheme.titleMedium),
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
            label: AppConstants.managerProjectDetailSettingsProjectName,
            hintText: AppConstants.managerProjectDetailSettingsProjectName,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _projectStatus ?? project?.status ?? 0,
            decoration: const InputDecoration(
              labelText: AppConstants.managerProjectDetailSettingsStatus,
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text(AppConstants.managerProjectDetailSettingsStatusActive)),
              DropdownMenuItem(value: 1, child: Text(AppConstants.managerProjectDetailSettingsStatusPaused)),
              DropdownMenuItem(value: 9, child: Text(AppConstants.managerProjectDetailSettingsStatusArchived)),
            ],
            onChanged: (status) {
              if (status != null) setState(() => _projectStatus = status);
            },
          ),
          const SizedBox(height: 12),
          ActionButton(
            label: AppConstants.managerProjectDetailSettingsSave,
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
            label: AppConstants.managerProjectDetailSettingsDeleteProject,
            isOutlined: true,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(AppConstants.managerProjectDetailSettingsDeleteConfirm),
                  content: const Text(AppConstants.managerProjectDetailSettingsDeleteWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(AppConstants.managerProjectDetailSettingsDeleteCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(AppConstants.managerProjectDetailSettingsDelete),
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
