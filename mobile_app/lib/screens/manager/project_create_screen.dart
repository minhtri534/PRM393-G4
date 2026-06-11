import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

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
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: const Text('Create Project'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DlssPageHeader(
              title: 'New Project',
              subtitle: 'Set up a data labeling project for your team',
            ),
            const SizedBox(height: 16),
            DlssCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Project Name',
                      hintText: 'Enter project name',
                      prefixIcon: const Icon(Icons.folder_outlined),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _guidelineController,
                      label: 'Guideline (optional)',
                      hintText: 'Labeling instructions for annotators',
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    Consumer<ManagerProvider>(
                      builder: (context, provider, _) => ActionButton(
                        label: 'Create Project',
                        variant: ActionButtonVariant.gradient,
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
          ],
        ),
      ),
    );
  }
}
