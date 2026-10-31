import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Base class for user-facing failures returned from the Domain layer.
abstract class Failure {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  /// Map an [AppException] to its corresponding domain [Failure].
  factory Failure.fromException(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } else if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } else if (exception is ServerException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } else if (exception is DataParsingException) {
      return DataParsingFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } else if (exception is StorageException) {
      return StorageFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    } else {
      return UnknownFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = AppLocalizations.defaultNetworkError,
    super.statusCode,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = AppLocalizations.defaultInvalidCredentials,
    super.statusCode = 401,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = AppLocalizations.defaultServerError,
    super.statusCode = 500,
  });
}

class DataParsingFailure extends Failure {
  const DataParsingFailure({
    super.message = AppLocalizations.defaultDataParsingError,
    super.statusCode,
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = AppLocalizations.defaultStorageError,
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = AppLocalizations.defaultUnknownError,
    super.statusCode,
  });
}
