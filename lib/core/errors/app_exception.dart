import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Base class for all domain and infrastructure exceptions in the application.
abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';
}

/// Thrown when there is no connectivity, DNS resolution fails, or a timeout occurs.
class NetworkException extends AppException {
  const NetworkException({
    super.message = AppLocalizations.defaultNetworkError,
    super.statusCode,
  });
}

/// Thrown for authentication issues: bad credentials, expired tokens, or 401 unauthorized.
class AuthException extends AppException {
  const AuthException({
    super.message = AppLocalizations.defaultInvalidCredentials,
    super.statusCode = 401,
  });
}

/// Thrown when the remote server returns a 5xx response or service unavailable.
class ServerException extends AppException {
  const ServerException({
    super.message = AppLocalizations.defaultServerError,
    super.statusCode = 500,
  });
}

/// Thrown when the response payload cannot be parsed or does not match expectations.
class DataParsingException extends AppException {
  const DataParsingException({
    super.message = AppLocalizations.defaultDataParsingError,
    super.statusCode,
  });
}

/// Thrown when secure storage encounters an issue.
class StorageException extends AppException {
  const StorageException({
    super.message = AppLocalizations.defaultStorageError,
    super.statusCode,
  });
}

/// Thrown for any unexpected exception.
class UnknownException extends AppException {
  const UnknownException({
    super.message = AppLocalizations.defaultUnknownError,
    super.statusCode,
  });
}
