import 'package:flutter_demo_app/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case that encapsulates the login interaction.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
