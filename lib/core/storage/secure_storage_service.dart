import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_demo_app/core/constants/app_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';

/// Contract for secure local persistence operations.
abstract class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();

  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveUserData({
    required int id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? avatar,
  });

  Future<Map<String, String?>> getUserData();
  Future<void> clearAuthData();
}

/// Concrete implementation of [ISecureStorageService] using [FlutterSecureStorage].
class SecureStorageService implements ISecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              encryptedSharedPreferences: true,
              resetOnError: true,
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException(message: 'Failed to write secure key: $key');
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException(message: 'Failed to read secure key: $key');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException(message: 'Failed to delete secure key: $key');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw const StorageException(message: 'Failed to clear secure storage');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await write(AppConstants.keyAccessToken, accessToken);
    if (refreshToken != null) {
      await write(AppConstants.keyRefreshToken, refreshToken);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return read(AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return read(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUserData({
    required int id,
    required String username,
    required String email,
    String? firstName,
    String? lastName,
    String? avatar,
  }) async {
    await write(AppConstants.keyUserId, id.toString());
    await write(AppConstants.keyUsername, username);
    await write(AppConstants.keyUserEmail, email);
    if (firstName != null) {
      await write(AppConstants.keyUserFirstName, firstName);
    }
    if (lastName != null) {
      await write(AppConstants.keyUserLastName, lastName);
    }
    if (avatar != null) {
      await write(AppConstants.keyUserAvatar, avatar);
    }
  }

  @override
  Future<Map<String, String?>> getUserData() async {
    final id = await read(AppConstants.keyUserId);
    final username = await read(AppConstants.keyUsername);
    final email = await read(AppConstants.keyUserEmail);
    final firstName = await read(AppConstants.keyUserFirstName);
    final lastName = await read(AppConstants.keyUserLastName);
    final avatar = await read(AppConstants.keyUserAvatar);

    return {
      AppConstants.keyUserId: id,
      AppConstants.keyUsername: username,
      AppConstants.keyUserEmail: email,
      AppConstants.keyUserFirstName: firstName,
      AppConstants.keyUserLastName: lastName,
      AppConstants.keyUserAvatar: avatar,
    };
  }

  @override
  Future<void> clearAuthData() async {
    await delete(AppConstants.keyAccessToken);
    await delete(AppConstants.keyRefreshToken);
    await delete(AppConstants.keyUserId);
    await delete(AppConstants.keyUsername);
    await delete(AppConstants.keyUserEmail);
    await delete(AppConstants.keyUserFirstName);
    await delete(AppConstants.keyUserLastName);
    await delete(AppConstants.keyUserAvatar);
  }
}

/// Riverpod provider exposing the [ISecureStorageService] singleton.
final secureStorageServiceProvider = Provider<ISecureStorageService>((ref) {
  return SecureStorageService();
});
