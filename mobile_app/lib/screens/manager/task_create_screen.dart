import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/manager/dataset_model.dart';
import '../../models/manager/project_model.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

class TaskCreateScreen extends StatefulWidget {
  final String? initialProjectId;

  const TaskCreateScreen({super.key, this.initialProjectId});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  String? _projectId;
  String? _datasetId;
  String? _annotatorId;
  bool _singleTaskMode = false;
  final _dataItemIdController = TextEditingController();

  @override
  void dispose() {
    _dataItemIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ManagerProvider>();
      if (provider.projects.isEmpty) {
        await provider.fetchProjects();
      }
      if (_projectId != null) {
        await provider.loadProjectDetail(_projectId!);
      }
    });
  }

  Future<void> _onProjectChanged(String? projectId) async {
    setState(() {
      _projectId = projectId;
      _datasetId = null;
      _annotatorId = null;
    });
    if (projectId != null) {
      await context.read<ManagerProvider>().loadProjectDetail(projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: const Text('Create Tasks'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DlssPageHeader(
                  title: 'Assign Tasks',
                  subtitle: 'Create labeling tasks for annotators',
                ),
                const SizedBox(height: 16),
                DlssCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Bulk by Dataset'),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Single Task'),
                          ),
                        ],
                        selected: {_singleTaskMode},
                        onSelectionChanged: (v) =>
                            setState(() => _singleTaskMode = v.first),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _projectId,
                        decoration: InputDecoration(
                          labelText: 'Project',
                          prefixIcon: const Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: provider.projects
                            .map(
                              (ProjectModel p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: _onProjectChanged,
                      ),
                      if (!_singleTaskMode) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _datasetId,
                          decoration: InputDecoration(
                            labelText: 'Dataset',
                            prefixIcon: const Icon(Icons.dataset_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: provider.datasets
                              .map(
                                (DatasetModel d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(
                                    '${d.name} (${d.totalItems ?? 0} items)',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _datasetId = v),
                        ),
                      ] else ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _dataItemIdController,
                          label: 'Data Item ID',
                          hintText: 'UUID of data item',
                          prefixIcon: const Icon(Icons.image_outlined),
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _annotatorId,
                        decoration: InputDecoration(
                          labelText: 'Annotator',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: provider.annotators
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.userId,
                                child: Text(r.userEmail),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _annotatorId = v),
                      ),
                      const SizedBox(height: 24),
                      ActionButton(
                        label: _singleTaskMode
                            ? 'Create Task'
                            : 'Bulk Create Tasks',
                        variant: ActionButtonVariant.gradient,
                        isLoading: provider.isLoading,
                        onPressed: () async {
                          if (_projectId == null || _annotatorId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Select project and annotator'),
                              ),
                            );
                            return;
                          }

                          late final bool ok;
                          if (_singleTaskMode) {
                            final dataItemId = _dataItemIdController.text
                                .trim();
                            if (dataItemId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter data item ID'),
                                ),
                              );
                              return;
                            }
                            ok = await provider.createTask(
                              projectId: _projectId!,
                              dataItemId: dataItemId,
                              annotatorId: _annotatorId!,
                            );
                          } else {
                            if (_datasetId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select dataset')),
                              );
                              return;
                            }
                            ok = await provider.bulkCreateTasks(
                              projectId: _projectId!,
                              datasetId: _datasetId!,
                              annotatorId: _annotatorId!,
                            );
                          }

                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tasks created')),
                            );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
