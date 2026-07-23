import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_card.dart';
import '../../widgets/dlss_page_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _genderController = TextEditingController();

  bool _isEditing = false;
  bool _initialized = false;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final provider = context.read<AuthProvider>();
    final profile = await provider.fetchProfile();
    if (!mounted) return;

    if (profile != null) {
      _applyProfileToForm(
        fullName: profile.fullName,
        email: profile.email,
        phone: profile.phoneNumber,
        address: profile.address,
        gender: profile.gender,
        dateOfBirth: profile.dateOfBirth,
      );
    }

    setState(() => _initialized = true);
  }

  void _applyProfileToForm({
    required String fullName,
    required String email,
    String? phone,
    String? address,
    String? gender,
    DateTime? dateOfBirth,
  }) {
    _fullNameController.text = fullName;
    _emailController.text = email;
    _phoneController.text = phone ?? '';
    _addressController.text = address ?? '';
    _genderController.text = gender ?? '';
    _dateOfBirth = dateOfBirth;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickDate() async {
    if (!_isEditing) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final gender = _genderController.text.trim();

    final ok = await provider.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: phone.isEmpty ? null : phone,
      address: address.isEmpty ? null : address,
      gender: gender.isEmpty ? null : gender,
      dateOfBirth: _dateOfBirth,
    );

    if (!mounted) return;

    if (ok) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.profileSaved)),
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.profileDeleteTitle),
        content: const Text(AppConstants.profileDeleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text(AppConstants.profileDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final ok = await auth.deleteAccount();
    if (!mounted) return;

    if (ok) {
      await chat.resetSession();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.profileDeleted)),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  void _cancelEdit(AuthProvider provider) {
    final profile = provider.profileDetail;
    if (profile != null) {
      _applyProfileToForm(
        fullName: profile.fullName,
        email: profile.email,
        phone: profile.phoneNumber,
        address: profile.address,
        gender: profile.gender,
        dateOfBirth: profile.dateOfBirth,
      );
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceSoftColor,
      appBar: AppBar(
        title: const Text(AppConstants.profileTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, _) {
          if (!_initialized ||
              (provider.isProfileBusy && provider.profileDetail == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = provider.profileDetail;
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage ?? AppConstants.errorGeneric,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ActionButton(
                      label: AppConstants.profileErrorRetry,
                      onPressed: _loadProfile,
                      width: 140,
                    ),
                  ],
                ),
              ),
            );
          }

          final initial = profile.fullName.isNotEmpty
              ? profile.fullName[0].toUpperCase()
              : AppConstants.profileFullNamePlaceholder;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DlssPageHeader(
                  title: AppConstants.profileTitle,
                  subtitle: AppConstants.profileSubtitle,
                ),
                const SizedBox(height: 16),
                DlssCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.roleName ?? AppConstants.profileRolePlaceholder} • ${profile.statusLabel}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DlssCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppConstants.profileDetailsTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: provider.isProfileBusy
                                  ? null
                                  : () {
                                      if (_isEditing) {
                                        _cancelEdit(provider);
                                      } else {
                                        setState(() => _isEditing = true);
                                      }
                                    },
                              child: Text(
                                _isEditing
                                    ? AppConstants.profileCancel
                                    : AppConstants.profileEdit,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _fullNameController,
                          label: AppConstants.profileFullName,
                          hintText: AppConstants.managerUserFormNameHint,
                          prefixIcon: const Icon(Icons.person_outline),
                          readOnly: !_isEditing,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? AppConstants.profileMissingName
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          label: AppConstants.profileEmail,
                          hintText: AppConstants.managerUserFormEmailHint,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          readOnly: !_isEditing,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return AppConstants.profileErrorMissingEmail;
                            }
                            if (!isValidEmail(v.trim())) {
                              return AppConstants.profileErrorInvalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          label: AppConstants.profilePhone,
                          hintText: AppConstants.managerUserFormPhoneHint,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          readOnly: !_isEditing,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          label: AppConstants.profileAddress,
                          hintText: AppConstants.profileAddressHint,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          readOnly: !_isEditing,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _genderController,
                          label: AppConstants.profileGender,
                          hintText: AppConstants.profileGenderHint,
                          prefixIcon: const Icon(Icons.wc_outlined),
                          readOnly: !_isEditing,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.profileDateOfBirth,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _isEditing ? _pickDate : null,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                              enabled: _isEditing,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _formatDate(_dateOfBirth),
                              style: TextStyle(
                                color: _dateOfBirth == null
                                    ? AppTheme.textHintColor
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.profileRole,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.badge_outlined),
                            enabled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(profile.roleName ?? '—'),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 24),
                          ActionButton(
                            label: AppConstants.profileSave,
                            isLoading: provider.isProfileBusy,
                            onPressed: _save,
                            icon: Icons.save_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: provider.isProfileBusy ? null : _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(AppConstants.profileDelete),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
