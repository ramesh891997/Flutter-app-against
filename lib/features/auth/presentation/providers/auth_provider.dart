import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/core/network/dio_client.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';
import 'package:flutter_demo_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_demo_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_demo_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Status representing the application authentication lifecycle.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Immutable state holder for authentication.
class AuthState {
  const AuthState({required this.status, this.session, this.errorMessage});

  const AuthState.initial()
    : status = AuthStatus.initial,
      session = null,
      errorMessage = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      session = null,
      errorMessage = null;

  const AuthState.authenticated(this.session)
    : status = AuthStatus.authenticated,
      errorMessage = null;

  const AuthState.unauthenticated([String? message])
    : status = AuthStatus.unauthenticated,
      session = null,
      errorMessage = message;

  const AuthState.error(String message)
    : status = AuthStatus.error,
      session = null,
      errorMessage = message;

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          session == other.session &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, session, errorMessage);
}

// ---------------------------------------------------------------------------
// Dependency Injection Providers
// ---------------------------------------------------------------------------

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorageService: storageService,
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

// ---------------------------------------------------------------------------
// Auth Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _repository = repository,
       super(const AuthState.initial());

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;

  /// Restores session from secure storage on app launch.
  Future<void> restoreSession() async {
    state = const AuthState.loading();
    try {
      final session = await _repository.restoreSession();
      if (session != null) {
        state = AuthState.authenticated(session);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Performs user login. Prevents duplicate concurrent requests.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (state.isLoading) return false;

    state = const AuthState.loading();
    try {
      final session = await _loginUseCase(
        username: username.trim(),
        password: password,
      );
      state = AuthState.authenticated(session);
      return true;
    } on Failure catch (failure) {
      state = AuthState.error(failure.message);
      return false;
    } catch (e) {
      state = const AuthState.error(
        AppLocalizations.defaultLoginUnexpectedError,
      );
      return false;
    }
  }

  /// Logs out and resets auth state.
  Future<void> logout() async {
    try {
      await _logoutUseCase();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  /// Callback when token refresh fails and session is invalidated.
  void handleSessionExpired() {
    state = const AuthState.unauthenticated(
      AppLocalizations.defaultSessionExpired,
    );
  }

  /// Clears any active error banner/message.
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}

/// Global AuthNotifier provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final repository = ref.watch(authRepositoryProvider);

  return AuthNotifier(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    repository: repository,
  );
});
