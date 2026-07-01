import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/email_validator.dart';
import '../../models/manager/yolo_label_file_model.dart';
import '../../providers/manager_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

class UserFormScreen extends StatefulWidget {
  final String? userId;

  const UserFormScreen({super.key, this.userId});

  bool get isEditing => userId != null;

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRoleId;
  int _selectedStatus = UserAccountStatus.active;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final provider = context.read<ManagerProvider>();
    await provider.fetchRoles();

    if (widget.isEditing) {
      await provider.loadUserDetail(widget.userId!);
      final user = provider.selectedUser;
      if (user != null && mounted) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _selectedRoleId = user.roleId;
        _selectedStatus = user.status;
        _initialized = true;
        setState(() {});
      }
    } else {
      final roles = provider.assignableRoles;
      if (roles.isNotEmpty) {
        _selectedRoleId = roles.first.id;
      }
      _initialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ManagerProvider>();
    final roleId = _selectedRoleId;
    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    final ok = widget.isEditing
        ? await provider.updateUser(
            userId: widget.userId!,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            roleId: roleId,
            status: _selectedStatus,
            password: _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text,
            phoneNumber: phone.isEmpty ? null : phone,
          )
        : await provider.createUser(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            roleId: roleId,
            status: _selectedStatus,
            phoneNumber: phone.isEmpty ? null : phone,
          );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
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
        title: Text(widget.isEditing ? 'Edit User' : 'Create User'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ManagerProvider>(
        builder: (context, provider, _) {
          if (!_initialized ||
              (widget.isEditing &&
                  provider.isLoading &&
                  provider.selectedUser == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.isEditing &&
              provider.selectedUser == null &&
              provider.state == ManagerLoadState.error) {
            return Center(
              child: Text(provider.errorMessage ?? 'User not found'),
            );
          }

          final roles = provider.assignableRoles;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DlssPageHeader(
                  title: widget.isEditing ? 'Edit User' : 'New User',
                  subtitle: widget.isEditing
                      ? 'Update account details or reset password'
                      : 'Create an Annotator or Reviewer account',
                ),
                const SizedBox(height: 16),
                DlssCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hintText: 'Enter full name',
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'user@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.mail_outline),
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: widget.isEditing
                              ? 'New Password (optional)'
                              : 'Password',
                          hintText: 'At least 8 characters',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (v) {
                            if (!widget.isEditing &&
                                (v == null || v.isEmpty)) {
                              return 'Password is required';
                            }
                            if (v != null &&
                                v.isNotEmpty &&
                                v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone (optional)',
                          hintText: '+84 ...',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRoleId,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: roles
                              .map(
                                (RoleModel role) => DropdownMenuItem(
                                  value: role.id,
                                  child: Text(role.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRoleId = value),
                          validator: (value) =>
                              value == null ? 'Role is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: const Icon(Icons.info_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: UserAccountStatus.active,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: UserAccountStatus.pendingEmailVerification,
                              child: Text('Pending email verification'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedStatus = value);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        ActionButton(
                          label: widget.isEditing ? 'Save Changes' : 'Create User',
                          variant: ActionButtonVariant.gradient,
                          isLoading: provider.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
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
