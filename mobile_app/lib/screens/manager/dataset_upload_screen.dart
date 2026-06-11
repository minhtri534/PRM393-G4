import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../models/manager/manager_models.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';

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
    if (!datasetOk || provider.datasets.isEmpty) return;

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

    if (multipartFiles.isEmpty) return;

    final uploadOk = await provider.uploadDatasetFiles(
      datasetId: dataset.id,
      files: multipartFiles,
    );

    if (uploadOk && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dataset uploaded successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Dataset')),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, _) {
          final projects = provider.projects;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
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
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _files.isEmpty
                        ? 'Select image files'
                        : '${_files.length} file(s) selected',
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                ActionButton(
                  label: 'Upload',
                  isLoading: provider.isLoading,
                  onPressed: _upload,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
