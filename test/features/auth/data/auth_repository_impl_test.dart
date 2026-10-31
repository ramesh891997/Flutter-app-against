import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/constants/app_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';
import 'package:flutter_demo_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_demo_app/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_demo_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorageService: mockSecureStorage,
    );
  });

  const tUsername = 'emilys';
  const tPassword = 'emilyspass';
  const tAuthResponseModel = AuthResponseModel(
    id: 1,
    username: 'emilys',
    email: 'emily@example.com',
    firstName: 'Emily',
    lastName: 'Johnson',
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  group('AuthRepositoryImpl', () {
    test(
      'login successfully stores tokens and user data and returns AuthSession',
      () async {
        when(
          () => mockRemoteDataSource.login(
            username: tUsername,
            password: tPassword,
          ),
        ).thenAnswer((_) async => tAuthResponseModel);

        when(
          () => mockSecureStorage.saveTokens(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockSecureStorage.saveUserData(
            id: any(named: 'id'),
            username: any(named: 'username'),
            email: any(named: 'email'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            avatar: any(named: 'avatar'),
          ),
        ).thenAnswer((_) async {});

        final session = await repository.login(
          username: tUsername,
          password: tPassword,
        );

        expect(session.id, 1);
        expect(session.username, 'emilys');
        expect(session.accessToken, 'test_access_token');

        verify(
          () => mockSecureStorage.saveTokens(
            accessToken: 'test_access_token',
            refreshToken: 'test_refresh_token',
          ),
        ).called(1);
        verify(
          () => mockSecureStorage.saveUserData(
            id: 1,
            username: 'emilys',
            email: 'emily@example.com',
            firstName: 'Emily',
            lastName: 'Johnson',
            avatar: null,
          ),
        ).called(1);
      },
    );

    test('login maps AuthException to AuthFailure', () async {
      when(
        () => mockRemoteDataSource.login(
          username: tUsername,
          password: tPassword,
        ),
      ).thenThrow(const AuthException(message: 'Invalid credentials'));

      expect(
        () => repository.login(username: tUsername, password: tPassword),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('logout clears credentials in secure storage', () async {
      when(() => mockSecureStorage.clearAuthData()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockSecureStorage.clearAuthData()).called(1);
    });

    test(
      'restoreSession returns valid session when credentials exist in storage',
      () async {
        when(
          () => mockSecureStorage.getAccessToken(),
        ).thenAnswer((_) async => 'stored_access_token');
        when(
          () => mockSecureStorage.getRefreshToken(),
        ).thenAnswer((_) async => 'stored_refresh_token');
        when(() => mockSecureStorage.getUserData()).thenAnswer(
          (_) async => {
            AppConstants.keyUserId: '1',
            AppConstants.keyUsername: 'emilys',
            AppConstants.keyUserEmail: 'emily@example.com',
            AppConstants.keyUserFirstName: 'Emily',
            AppConstants.keyUserLastName: 'Johnson',
            AppConstants.keyUserAvatar: null,
          },
        );

        final session = await repository.restoreSession();

        expect(session, isNotNull);
        expect(session!.username, 'emilys');
        expect(session.accessToken, 'stored_access_token');
      },
    );

    test('restoreSession returns null when token does not exist', () async {
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      final session = await repository.restoreSession();

      expect(session, isNull);
    });
  });
}
