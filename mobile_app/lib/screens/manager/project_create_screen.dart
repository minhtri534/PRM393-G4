import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _guidelineController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _guidelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Project Name',
                hintText: 'Enter project name',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              CustomTextField(
                controller: _guidelineController,
                label: 'Guideline (optional)',
                hintText: 'Labeling instructions for annotators',
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              Consumer<ManagerProvider>(
                builder: (context, provider, _) => ActionButton(
                  label: 'Create Project',
                  isLoading: provider.isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final ok = await provider.createProject(
                      name: _nameController.text.trim(),
                      guideline: _guidelineController.text.trim().isEmpty
                          ? null
                          : _guidelineController.text.trim(),
                    );
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
