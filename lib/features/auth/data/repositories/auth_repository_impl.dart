import 'package:flutter_demo_app/core/constants/app_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';
import 'package:flutter_demo_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Concrete implementation of [AuthRepository] orchestrating remote data and secure storage.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required ISecureStorageService secureStorageService,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorageService;

  final AuthRemoteDataSource _remoteDataSource;
  final ISecureStorageService _secureStorage;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    try {
      final responseModel = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      // Persist credentials securely
      await _secureStorage.saveTokens(
        accessToken: responseModel.accessToken,
        refreshToken: responseModel.refreshToken,
      );

      await _secureStorage.saveUserData(
        id: responseModel.id,
        username: responseModel.username,
        email: responseModel.email,
        firstName: responseModel.firstName,
        lastName: responseModel.lastName,
        avatar: responseModel.image,
      );

      return responseModel.toEntity();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (_) {
      throw const UnknownFailure(
        message: AppLocalizations.defaultLoginFailed,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _secureStorage.clearAuthData();
    } catch (_) {
      throw const StorageFailure(
        message: AppLocalizations.defaultLogoutFailed,
      );
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    try {
      final token = await _secureStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final userData = await _secureStorage.getUserData();
      final idStr = userData[AppConstants.keyUserId];
      final username = userData[AppConstants.keyUsername];
      final email = userData[AppConstants.keyUserEmail];

      if (idStr == null || username == null || email == null) {
        await _secureStorage.clearAuthData();
        return null;
      }

      final id = int.tryParse(idStr) ?? 0;
      final firstName = userData[AppConstants.keyUserFirstName];
      final lastName = userData[AppConstants.keyUserLastName];
      final avatar = userData[AppConstants.keyUserAvatar];
      final refreshToken = await _secureStorage.getRefreshToken();

      // Return persisted session
      return AuthSession(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        image: avatar,
        accessToken: token,
        refreshToken: refreshToken,
      );
    } catch (_) {
      await _secureStorage.clearAuthData();
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
