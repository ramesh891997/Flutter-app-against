import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';

/// Contract for authentication operations in the domain layer.
abstract class AuthRepository {
  /// Authenticates with username and password.
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  /// Logs out by clearing stored credentials and invalidating active session.
  Future<void> logout();

  /// Attempts to restore a persisted session on application launch.
  Future<AuthSession?> restoreSession();

  /// Returns whether a valid session token exists locally.
  Future<bool> isAuthenticated();
}
