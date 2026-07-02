import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/manager_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_badge.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

class DatasetDetailScreen extends StatefulWidget {
  final String datasetId;

  const DatasetDetailScreen({super.key, required this.datasetId});

  @override
  State<DatasetDetailScreen> createState() => _DatasetDetailScreenState();
}

class _DatasetDetailScreenState extends State<DatasetDetailScreen> {
  final _nameController = TextEditingController();
  final _versionController = TextEditingController();
  final _sourceNameController = TextEditingController();
  final _itemsJsonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().loadDatasetDetail(widget.datasetId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _sourceNameController.dispose();
    _itemsJsonController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>>? _parseItemsJson() {
    try {
      final decoded = jsonDecode(_itemsJsonController.text.trim());
      if (decoded is! List) return null;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _addFiles(ManagerProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result == null) return;

    final multipartFiles = <MultipartFile>[];
    for (final file in result.files) {
      if (kIsWeb && file.bytes != null) {
        multipartFiles.add(
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        );
      } else if (file.path != null) {
        multipartFiles.add(
          await MultipartFile.fromFile(file.path!, filename: file.name),
        );
      }
    }

    if (multipartFiles.isNotEmpty) {
      final ok = await provider.uploadDatasetFiles(
        datasetId: widget.datasetId,
        files: multipartFiles,
      );
      if (mounted && !ok && provider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        final dataset = provider.selectedDataset;
        if (provider.isLoading && dataset == null) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceSoftColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (dataset == null) {
          return Scaffold(
            backgroundColor: AppTheme.surfaceSoftColor,
            appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
            body: const Center(child: Text('Dataset not found')),
          );
        }

        if (_nameController.text.isEmpty) {
          _nameController.text = dataset.name;
        }

        return Scaffold(
          backgroundColor: AppTheme.surfaceSoftColor,
          appBar: AppBar(
            title: Text(dataset.name),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            children: [
              DlssPageHeader(
                title: dataset.name,
                subtitle: dataset.projectName ?? 'Dataset details',
              ),
              const SizedBox(height: 16),
              DlssCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dataset_outlined,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataset.projectName ?? 'Project',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${dataset.totalItems ?? 0} items',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    DlssBadge(
                      label: 'Active',
                      variant: DlssBadgeVariant.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DlssCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dataset settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Dataset Name',
                      hintText: 'Rename dataset',
                    ),
                    ActionButton(
                      label: 'Save Name',
                      variant: ActionButtonVariant.gradient,
                      isLoading: provider.isLoading,
                      onPressed: () => provider.updateDatasetName(
                        widget.datasetId,
                        _nameController.text.trim(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      label: 'Add More Files',
                      variant: ActionButtonVariant.outline,
                      onPressed: () => _addFiles(provider),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DlssCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Import data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _itemsJsonController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Upload items (JSON array)',
                        hintText: '[{"fileName":"a.jpg","fileUrl":"..."}]',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    ActionButton(
                      label: 'Upload Items JSON',
                      variant: ActionButtonVariant.outline,
                      isLoading: provider.isLoading,
                      onPressed: () async {
                        final items = _parseItemsJson();
                        if (items == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid JSON array')),
                          );
                          return;
                        }
                        await provider.uploadDatasetItems(
                          datasetId: widget.datasetId,
                          items: items,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _sourceNameController,
                      label: 'External source name',
                      hintText: 'e.g. COCO import',
                    ),
                    ActionButton(
                      label: 'Import External Items',
                      variant: ActionButtonVariant.outline,
                      isLoading: provider.isLoading,
                      onPressed: () async {
                        final items = _parseItemsJson();
                        final source = _sourceNameController.text.trim();
                        if (items == null || source.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter source name and valid JSON'),
                            ),
                          );
                          return;
                        }
                        await provider.importDatasetExternal(
                          datasetId: widget.datasetId,
                          sourceName: source,
                          items: items,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DlssCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Versions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _versionController,
                            label: 'Version name',
                            hintText: 'v1.0',
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_versionController.text.trim().isEmpty) return;
                            await provider.createDatasetVersion(
                              datasetId: widget.datasetId,
                              versionName: _versionController.text.trim(),
                            );
                            _versionController.clear();
                          },
                          icon: const Icon(Icons.save),
                        ),
                      ],
                    ),
                    ...provider.datasetVersions.map(
                      (v) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(v.versionName),
                        subtitle: Text(v.createdAt?.toLocal().toString() ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () => provider.restoreDatasetVersion(v.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ActionButton(
                label: 'Delete Dataset',
                variant: ActionButtonVariant.outline,
                onPressed: () async {
                  final ok = await provider.deleteDataset(widget.datasetId);
                  if (ok && context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
