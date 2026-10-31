import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockAuthRepository mockAuthRepository;
  late AuthNotifier authNotifier;

  const tSession = AuthSession(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    accessToken: 'valid_token',
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockAuthRepository();

    authNotifier = AuthNotifier(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      repository: mockAuthRepository,
    );
  });

  group('AuthNotifier', () {
    test('initial state has initial status', () {
      expect(authNotifier.state.status, AuthStatus.initial);
      expect(authNotifier.state.isAuthenticated, isFalse);
    });

    test('successful login updates state to authenticated', () async {
      when(
        () => mockLoginUseCase(username: 'emilys', password: 'emilyspass'),
      ).thenAnswer((_) async => tSession);

      final success = await authNotifier.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(success, isTrue);
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.session, tSession);
      expect(authNotifier.state.isAuthenticated, isTrue);
    });

    test('failed login updates state to error with failure message', () async {
      when(
        () => mockLoginUseCase(username: 'emilys', password: 'wrongpassword'),
      ).thenThrow(const AuthFailure(message: 'Invalid credentials'));

      final success = await authNotifier.login(
        username: 'emilys',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      expect(authNotifier.state.status, AuthStatus.error);
      expect(authNotifier.state.errorMessage, 'Invalid credentials');
      expect(authNotifier.state.isAuthenticated, isFalse);
    });

    test('prevents duplicate concurrent login calls', () async {
      when(
        () => mockLoginUseCase(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return tSession;
      });

      final future1 = authNotifier.login(
        username: 'emilys',
        password: 'emilyspass',
      );
      final future2 = authNotifier.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      final results = await Future.wait([future1, future2]);

      expect(results[0], isTrue);
      expect(results[1], isFalse); // Second request was ignored
      verify(
        () => mockLoginUseCase(username: 'emilys', password: 'emilyspass'),
      ).called(1);
    });

    test('logout clears session and sets unauthenticated', () async {
      when(() => mockLogoutUseCase()).thenAnswer((_) async {});

      await authNotifier.logout();

      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.session, isNull);
      verify(() => mockLogoutUseCase()).called(1);
    });

    test('restoreSession authenticates when session is restored', () async {
      when(
        () => mockAuthRepository.restoreSession(),
      ).thenAnswer((_) async => tSession);

      await authNotifier.restoreSession();

      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.session, tSession);
    });

    test(
      'restoreSession sets unauthenticated when no session exists',
      () async {
        when(
          () => mockAuthRepository.restoreSession(),
        ).thenAnswer((_) async => null);

        await authNotifier.restoreSession();

        expect(authNotifier.state.status, AuthStatus.unauthenticated);
        expect(authNotifier.state.session, isNull);
      },
    );
  });
}
