import 'package:flutter_demo_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case that encapsulates the logout interaction.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
