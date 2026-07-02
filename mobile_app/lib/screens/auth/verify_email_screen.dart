import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/navigation/role_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/dlss_background.dart';
import '../../widgets/dlss_card.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final TextEditingController _otpController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    final response = await context.read<AuthProvider>().resendVerificationOtp(
      widget.email,
    );
    if (!mounted || response == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A new verification code was sent to ${widget.email}.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DlssBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: DlssCard(
                      variant: DlssCardVariant.glass,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check your email',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondaryColor,
                                          ),
                                    ),
                                    Text(
                                      'Verify your account',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'We sent a 6-digit verification code to:',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.email,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Open your inbox and enter the code below. '
                                  'If you do not see it, check your spam folder.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (authProvider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(
                                  alpha: 0.08,
                                ),
                                border: Border.all(
                                  color: AppTheme.errorColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.errorColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: CustomTextField(
                              controller: _otpController,
                              label: 'Verification code',
                              hintText: 'Enter 6-digit code',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.pin_outlined),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Verification code is required';
                                }
                                if (value.length != 6) {
                                  return 'Enter the 6-digit code';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          ActionButton(
                            label: 'Verify & Continue',
                            variant: ActionButtonVariant.gradient,
                            isLoading: authProvider.isLoading,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final success = await authProvider.verifyEmailOtp(
                                email: widget.email,
                                otpCode: _otpController.text.trim(),
                              );
                              if (!mounted || !success) return;
                              final route = homeRouteForRole(
                                authProvider.userProfile?.roleName,
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                route,
                                (route) => false,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _resendCode,
                            child: const Text('Resend code'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
