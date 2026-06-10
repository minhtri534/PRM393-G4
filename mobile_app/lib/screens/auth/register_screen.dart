import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Creating account...'),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (authProvider.errorMessage != null)
                    Container(
                      padding:
                          const EdgeInsets.all(
                            AppConstants.paddingMedium,
                          ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFFF43F5E),
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFF43F5E),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFF43F5E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          hintText: 'Your full name',
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: AppConstants.paddingLarge,
                        ),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'your@email.com',
                          keyboardType:
                              TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        const SizedBox(
                          height: AppConstants.paddingLarge,
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Create a strong password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: AppConstants.paddingLarge,
                        ),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number (Optional)',
                          hintText: '+1 (555) 000-0000',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: AppConstants.paddingLarge,
                  ),
                  ActionButton(
                    label: 'Create Account',
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!
                          .validate()) {
                        final success =
                            await authProvider.register(
                          fullName: _fullNameController
                              .text
                              .trim(),
                          email: _emailController.text.trim(),
                          password:
                              _passwordController
                                  .text,
                          phoneNumber: _phoneController
                              .text
                              .trim()
                              .isEmpty
                              ? null
                              : _phoneController
                                  .text
                                  .trim(),
                        );

                        if (success) {
                          if (mounted) {
                            Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                              '/tasks',
                              (route) => false,
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context)
                                .pop(),
                        child: Text(
                          'Sign in',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
