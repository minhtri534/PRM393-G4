import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/action_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_widget.dart' as error_widget;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      const Text('Logging in...'),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to your tasks',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
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
                          GestureDetector(
                            onTap: () =>
                                authProvider.clearError(),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFFF43F5E),
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
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon:
                              const Icon(Icons.email_outlined),
                          validator: validateEmail,
                        ),
                        const SizedBox(
                          height: AppConstants.paddingLarge,
                        ),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          obscureText: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: AppConstants.paddingLarge,
                  ),
                  ActionButton(
                    label: 'Sign In',
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success =
                            await authProvider.login(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        if (success) {
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/tasks',
                              (route) => false,
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context)
                                .pushNamed('/register'),
                        child: Text(
                          'Sign up',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                fontWeight: FontWeight.w600,
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
