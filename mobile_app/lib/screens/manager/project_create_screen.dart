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
        title: const Text(AppConstants.managerProjectCreateCreateProjectBar),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DlssPageHeader(
              title: AppConstants.managerProjectCreateNewProjectTitle,
              subtitle: AppConstants.managerProjectCreateNewProjectSubtitle,
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
                      label: AppConstants.managerProjectCreateProjectName,
                      hintText: AppConstants.managerProjectCreateProjectNameHint,
                      prefixIcon: const Icon(Icons.folder_outlined),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? AppConstants.managerProjectCreateProjectNameMissing
                          : null,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _guidelineController,
                      label: AppConstants.managerProjectCreateGuideline,
                      hintText: AppConstants.managerProjectCreateGuidelineHint,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    Consumer<ManagerProvider>(
                      builder: (context, provider, _) => ActionButton(
                        label: AppConstants.managerProjectCreateCreateProject,
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
