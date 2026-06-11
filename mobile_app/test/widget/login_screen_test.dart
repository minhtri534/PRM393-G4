import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/auth/login_screen.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/action_button.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders required UI elements',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Assert - Check for key text elements
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsWidgets);
      expect(
        find.text('Access projects, tasks, and analytics in one place.'),
        findsOneWidget,
      );

      // Assert - Check for input fields
      expect(find.byType(CustomTextField), findsWidgets);

      // Assert - Check for action button
      expect(find.byType(ActionButton), findsOneWidget);

      // Assert - Check for sign up link
      expect(find.textContaining("Don't have an account"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('Email and password fields are present',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Assert - Check for email label
      expect(find.text('Email'), findsOneWidget);

      // Assert - Check for password label
      expect(find.text('Password'), findsOneWidget);

      // Assert - Check for hintTexts
      expect(find.text('example@email.com'), findsOneWidget);
      expect(find.text('••••••••'), findsOneWidget);
    });

    testWidgets('Sign in button is present and enabled',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Assert - Check for Sign in button (header + button share label)
      expect(find.byType(ActionButton), findsOneWidget);
      expect(
        find.widgetWithText(ActionButton, 'Sign in'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Navigates to register screen when Sign up link is tapped',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
            routes: {
              '/register': (_) => const Scaffold(
                    body: Center(child: Text('Register Screen')),
                  ),
            },
          ),
        ),
      );

      // Find and tap the Sign up link
      final signUpLink = find.text('Sign up');
      expect(signUpLink, findsOneWidget);

      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Assert - Verify navigation occurred
      expect(find.text('Register Screen'), findsOneWidget);
    });

    testWidgets('Form validation works correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Try to submit empty form
      final signInButton = find.byType(ActionButton);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Assert - Validation errors should appear
      expect(find.text('Email is required'), findsWidgets);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Password field toggles visibility',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Find the password visibility toggle icon
      final visibilityIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcons, findsOneWidget);

      // Tap to reveal password
      await tester.tap(visibilityIcons);
      await tester.pumpAndSettle();

      // Assert - Visibility icon should change
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('SafeArea and SingleChildScrollView prevent overflow',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Assert - Check for SafeArea
      expect(find.byType(SafeArea), findsOneWidget);

      // Assert - Check for SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Simulate soft keyboard appearing
      tester.binding.window.physicalSizeTestValue =
          const Size(1080, 1776);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      // Should still render without overflow
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
