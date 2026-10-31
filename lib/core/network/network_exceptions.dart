import 'package:dio/dio.dart';

import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Helper to translate [DioException] and HTTP status codes into typed [AppException].
class NetworkExceptionHandler {
  const NetworkExceptionHandler._();

  static AppException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: AppLocalizations.defaultConnectionTimeout,
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: AppLocalizations.defaultConnectionError,
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: AppLocalizations.defaultCertificateError,
        );

      case DioExceptionType.cancel:
        return const NetworkException(
          message: AppLocalizations.defaultRequestCancelled,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.unknown:
      default:
        final message = error.message;
        if (message != null && message.toLowerCase().contains('socket')) {
          return const NetworkException(
            message: AppLocalizations.defaultNoInternet,
          );
        }
        return UnknownException(
          message:
              error.message ?? AppLocalizations.defaultUnexpectedNetworkError,
        );
    }
  }

  static AppException _handleBadResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;
    } else if (data is String && data.isNotEmpty) {
      serverMessage = data;
    }

    switch (statusCode) {
      case 400:
        if (serverMessage != null &&
            serverMessage.toLowerCase().contains('invalid credentials')) {
          return AuthException(message: serverMessage, statusCode: 400);
        }
        return AuthException(
          message: serverMessage ?? AppLocalizations.defaultInvalidRequest,
          statusCode: 400,
        );

      case 401:
        return AuthException(
          message: serverMessage ?? AppLocalizations.defaultSessionExpired,
          statusCode: 401,
        );

      case 403:
        return AuthException(
          message: serverMessage ?? AppLocalizations.defaultAccessDenied,
          statusCode: 403,
        );

      case 404:
        return ServerException(
          message: serverMessage ?? AppLocalizations.defaultNotFound,
          statusCode: 404,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: serverMessage ?? AppLocalizations.defaultServerError,
          statusCode: statusCode,
        );

      default:
        return ServerException(
          message:
              serverMessage ?? AppLocalizations.defaultUnexpectedServerError,
          statusCode: statusCode,
        );
    }
  }
}
