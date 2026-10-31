import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/constants/app_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService storageService;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    storageService = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test(
      'saveTokens writes accessToken and refreshToken to secure storage',
      () async {
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await storageService.saveTokens(
          accessToken: 'access123',
          refreshToken: 'refresh123',
        );

        verify(
          () => mockStorage.write(
            key: AppConstants.keyAccessToken,
            value: 'access123',
          ),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: AppConstants.keyRefreshToken,
            value: 'refresh123',
          ),
        ).called(1);
      },
    );

    test('getAccessToken returns value from storage', () async {
      when(
        () => mockStorage.read(key: AppConstants.keyAccessToken),
      ).thenAnswer((_) async => 'stored_token');

      final token = await storageService.getAccessToken();

      expect(token, 'stored_token');
      verify(
        () => mockStorage.read(key: AppConstants.keyAccessToken),
      ).called(1);
    });

    test('clearAuthData deletes all auth related keys', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await storageService.clearAuthData();

      verify(
        () => mockStorage.delete(key: AppConstants.keyAccessToken),
      ).called(1);
      verify(
        () => mockStorage.delete(key: AppConstants.keyRefreshToken),
      ).called(1);
      verify(() => mockStorage.delete(key: AppConstants.keyUserId)).called(1);
      verify(() => mockStorage.delete(key: AppConstants.keyUsername)).called(1);
      verify(
        () => mockStorage.delete(key: AppConstants.keyUserEmail),
      ).called(1);
    });

    test('saveUserData stores user profile attributes', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await storageService.saveUserData(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
      );

      verify(
        () => mockStorage.write(key: AppConstants.keyUserId, value: '1'),
      ).called(1);
      verify(
        () => mockStorage.write(key: AppConstants.keyUsername, value: 'emilys'),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: AppConstants.keyUserEmail,
          value: 'emily@example.com',
        ),
      ).called(1);
    });

    test('wraps storage failures in StorageException', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('disk failure'));

      expect(
        () => storageService.write('test_key', 'test_val'),
        throwsA(isA<StorageException>()),
      );
    });
  });
}
