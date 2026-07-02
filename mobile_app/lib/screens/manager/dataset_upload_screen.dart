import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/manager/project_model.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

class DatasetUploadScreen extends StatefulWidget {
  const DatasetUploadScreen({super.key});

  @override
  State<DatasetUploadScreen> createState() => _DatasetUploadScreenState();
}

class _DatasetUploadScreenState extends State<DatasetUploadScreen> {
  final _nameController = TextEditingController();
  String? _selectedProjectId;
  List<PlatformFile> _files = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerProvider>().fetchProjects();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() => _files = result.files);
    }
  }

  Future<void> _upload() async {
    final provider = context.read<ManagerProvider>();
    final projectId = _selectedProjectId;
    final name = _nameController.text.trim();

    if (projectId == null || name.isEmpty || _files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select project, name, and files')),
      );
      return;
    }

    final datasetOk = await provider.createDataset(
      projectId: projectId,
      name: name,
    );
    if (!datasetOk || provider.datasets.isEmpty) {
      if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
      return;
    }

    final dataset = provider.datasets.first;
    final multipartFiles = <MultipartFile>[];

    for (final file in _files) {
      if (kIsWeb) {
        if (file.bytes != null) {
          multipartFiles.add(
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      } else if (file.path != null) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
        );
      }
    }

    if (multipartFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read selected files')),
        );
      }
      return;
    }

    final uploadOk = await provider.uploadDatasetFiles(
      datasetId: dataset.id,
      files: multipartFiles,
    );

    if (uploadOk && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dataset uploaded successfully')),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: const Text('Upload Dataset'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, _) {
          final projects = provider.projects;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DlssPageHeader(
                  title: 'Upload Dataset',
                  subtitle: 'Add image files to a project dataset',
                ),
                const SizedBox(height: 16),
                DlssCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProjectId,
                        decoration: InputDecoration(
                          labelText: 'Project',
                          prefixIcon: const Icon(Icons.folder_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: projects
                            .map(
                              (ProjectModel p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedProjectId = v),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Dataset Name',
                        hintText: 'e.g. Street Images Batch 1',
                        prefixIcon: const Icon(Icons.dataset_outlined),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _files.isEmpty
                                  ? Icons.cloud_upload_outlined
                                  : Icons.check_circle_outline,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _files.isEmpty
                                  ? 'No files selected'
                                  : '${_files.length} file(s) selected',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            ActionButton(
                              label: _files.isEmpty
                                  ? 'Select image files'
                                  : 'Change selection',
                              variant: ActionButtonVariant.outline,
                              onPressed: _pickFiles,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge),
                      ActionButton(
                        label: 'Upload',
                        variant: ActionButtonVariant.gradient,
                        isLoading: provider.isLoading,
                        onPressed: _upload,
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
