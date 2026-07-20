import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/email_validator.dart';
import '../../models/manager/role_model.dart';
import '../../models/manager/user_account_status.dart';
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
  final _roleController = TextEditingController();
  final _statusController = TextEditingController(
    text: AppConstants.managerUserFormStatusActive,
  );

  String? _selectedRoleId;
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
        _phoneController.text =
            user.phoneNumber ?? AppConstants.managerUserFormNoPhone;
        _roleController.text =
            user.roleName ?? AppConstants.managerUserFormUnknownRole;
        _statusController.text = AppConstants.managerUserFormStatusActive;
        _selectedRoleId = user.roleId;
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
    _roleController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ManagerProvider>();
    final roleId = _selectedRoleId;
    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.managerUserFormMissingRoleAlert),
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    final ok = widget.isEditing
        ? await provider.updateUser(
            userId: widget.userId!,
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            roleId: roleId,
            status: UserAccountStatus.active,
            phoneNumber: phone.isEmpty ? null : phone,
          )
        : await provider.createUser(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            roleId: roleId,
            status: UserAccountStatus.active,
            phoneNumber: phone.isEmpty ? null : phone,
          );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? AppConstants.managerUserFormUserDetails
              : AppConstants.managerUserFormCreateUser,
        ),
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
              child: Text(
                provider.errorMessage ??
                    AppConstants.managerUserFormUserNotFound,
              ),
            );
          }

          final roles = provider.assignableRoles;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DlssPageHeader(
                  title: widget.isEditing
                      ? AppConstants.managerUserFormUserDetails
                      : AppConstants.managerUserFormCreateUser,
                  subtitle: widget.isEditing
                      ? AppConstants.managerUserFormViewAccount
                      : AppConstants.managerUserFormCreateAccount,
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
                          label: AppConstants.managerUserFormName,
                          hintText: AppConstants.managerUserFormNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                          readOnly: widget.isEditing,
                          validator: widget.isEditing
                              ? null
                              : (v) => v == null || v.trim().isEmpty
                                    ? AppConstants.managerUserFormMissingName
                                    : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: AppConstants.managerUserFormEmail,
                          hintText: AppConstants.managerUserFormEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.mail_outline),
                          readOnly: widget.isEditing,
                          validator: widget.isEditing ? null : validateEmail,
                        ),
                        if (!widget.isEditing) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: AppConstants.managerUserFormPassword,
                            hintText: AppConstants.managerUserFormPasswordHint,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppConstants
                                    .managerUserFormMissingPassword;
                              }
                              if (v.length < 8) {
                                return AppConstants
                                    .managerUserFormInvalidPassword;
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: AppConstants.managerUserFormPhone,
                          hintText: AppConstants.managerUserFormPhoneHint,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          readOnly: widget.isEditing,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRoleId,
                          decoration: InputDecoration(
                            labelText: AppConstants.managerUserFormRole,
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
                          validator: (value) => value == null
                              ? AppConstants.managerUserFormMissingRole
                              : null,
                        ),
                        if (widget.isEditing) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _statusController,
                            label: AppConstants.managerUserFormStatus,
                            hintText: AppConstants.managerUserFormStatusActive,
                            prefixIcon: const Icon(Icons.info_outline),
                            readOnly: false,
                          ),
                        ],
                        ...[
                          const SizedBox(height: 24),
                          ActionButton(
                            label: widget.isEditing
                                ? AppConstants.managerUserFormUpdateUser
                                : AppConstants.managerUserFormCreateUser,
                            variant: ActionButtonVariant.gradient,
                            isLoading: provider.isLoading,
                            onPressed: _submit,
                          ),
                        ],
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
