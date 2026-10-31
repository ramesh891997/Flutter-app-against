import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/app/router/route_names.dart';
import 'package:flutter_demo_app/app/theme/app_theme.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/features/auth/presentation/screens/splash_screen.dart';

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
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
        GoRoute(
          path: '/products',
          name: RouteNames.products,
          builder: (context, state) =>
              const Scaffold(body: Text('Products Screen')),
        ),
      ],
    );

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
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('SplashScreen Widget Tests', () {
    testWidgets('renders brand title, logo, and loader then transitions', (
      tester,
    ) async {
      when(
        () => mockAuthRepository.restoreSession(),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Explore quality products'), findsOneWidget);
      expect(find.byType(AppLoader), findsOneWidget);

      // Advance clock past minimum splash timer
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
