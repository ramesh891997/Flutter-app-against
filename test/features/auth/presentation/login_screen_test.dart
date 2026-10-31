import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/app/theme/app_theme.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/features/auth/presentation/screens/login_screen.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            loginUseCase: mockLoginUseCase,
            logoutUseCase: mockLogoutUseCase,
            repository: mockAuthRepository,
          ),
        ),
      ],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all essential login elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Sign In'), findsNWidgets(2)); // Card header & Button
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Use demo credentials (emilys)'), findsOneWidget);
    });

    testWidgets('displays validation errors when fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap Sign In without filling fields
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('clears validation error dynamically as user types valid input', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Trigger validation errors first
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);

      // Enter valid text into username field
      final usernameField = find.byType(TextFormField).first;
      await tester.enterText(usernameField, 'john_doe');
      await tester.pumpAndSettle();

      // Username error should disappear immediately
      expect(find.text('Username is required'), findsNothing);
      expect(find.text('Username must be at least 3 characters'), findsNothing);
    });

    testWidgets('surfaces login errors via floating SnackBar toast', (
      tester,
    ) async {
      when(
        () => mockLoginUseCase(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure(message: 'Invalid credentials'));

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in demo credentials
      final demoButton = find.text('Use demo credentials (emilys)');
      await tester.tap(demoButton);
      await tester.pumpAndSettle();

      // Submit
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Should display toast SnackBar, NOT inline banner
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('auto-fills credentials when demo button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final demoButton = find.text('Use demo credentials (emilys)');
      await tester.tap(demoButton);
      await tester.pumpAndSettle();

      expect(find.text('emilys'), findsOneWidget);
      expect(find.text('emilyspass'), findsOneWidget);
    });
  });
}
