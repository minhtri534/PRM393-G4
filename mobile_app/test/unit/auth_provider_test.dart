import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/constants/app_constants.dart';
import 'package:mobile_app/models/auth/auth_response.dart';
import 'package:mobile_app/models/auth/login_request.dart';
import 'package:mobile_app/models/auth/register_request.dart';
import 'package:mobile_app/models/auth/user_profile.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      LoginRequest(email: 'fallback@example.com', password: 'fallback'),
    );
    registerFallbackValue(
      RegisterRequest(
        fullName: 'Fallback User',
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });

  group('AuthProvider Tests', () {
    late MockAuthRepository mockAuthRepository;
    late AuthProvider authProvider;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authProvider = AuthProvider(authRepository: mockAuthRepository);
    });

    test('AuthProvider initializes with initial state', () {
      expect(authProvider.state, AuthState.initial);
      expect(authProvider.userProfile, null);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, null);
    });

    test('Login successfully updates state to authenticated', () async {
      const email = 'test@example.com';
      const password = 'password123';
      final userProfile = UserProfile(
        id: '123',
        fullName: 'Test User',
        email: email,
        roleId: 'role-1',
        roleName: 'Annotator',
        status: 1,
      );
      final authResponse = AuthResponse(
        accessToken: 'token-123',
        refreshToken: 'refresh-token-123',
        user: userProfile,
      );

      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => authResponse);

      final result = await authProvider.login(email, password);

      expect(result, true);
      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.userProfile, userProfile);
      expect(authProvider.errorMessage, null);
      verify(() => mockAuthRepository.login(any())).called(1);
    });

    test('Login sets error state on failure', () async {
      when(() => mockAuthRepository.login(any()))
          .thenThrow(Exception('Invalid credentials'));

      final result = await authProvider.login('test@example.com', 'wrongpassword');

      expect(result, false);
      expect(authProvider.state, AuthState.error);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, AppConstants.errorGeneric);
    });

    test('Logout clears authentication state', () async {
      final userProfile = UserProfile(
        id: '123',
        fullName: 'Test User',
        email: 'test@example.com',
        roleId: 'role-1',
        roleName: 'Annotator',
        status: 1,
      );
      final authResponse = AuthResponse(
        accessToken: 'token-123',
        refreshToken: 'refresh-token-123',
        user: userProfile,
      );

      when(() => mockAuthRepository.login(any()))
          .thenAnswer((_) async => authResponse);

      await authProvider.login('test@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      await authProvider.logout();

      expect(authProvider.state, AuthState.unauthenticated);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.userProfile, null);
      expect(authProvider.errorMessage, null);
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('Register successfully updates state to authenticated', () async {
      final userProfile = UserProfile(
        id: '456',
        fullName: 'New User',
        email: 'newuser@example.com',
        roleId: 'role-1',
        roleName: 'Annotator',
        status: 1,
      );
      final authResponse = AuthResponse(
        accessToken: 'token-456',
        refreshToken: 'refresh-token-456',
        user: userProfile,
      );

      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => authResponse);

      final result = await authProvider.register(
        fullName: 'New User',
        email: 'newuser@example.com',
        password: 'password123',
        phoneNumber: '555-0000',
      );

      expect(result, true);
      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.userProfile, userProfile);
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    test('clearError removes error message', () async {
      when(() => mockAuthRepository.login(any()))
          .thenThrow(Exception('Invalid credentials'));

      await authProvider.login('test@example.com', 'wrong');
      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();

      expect(authProvider.errorMessage, null);
    });
  });
}
