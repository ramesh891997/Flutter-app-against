import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'package:flutter_demo_app/core/constants/api_constants.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';

/// Interceptor that handles Bearer token attachment, safe logging (redacting
/// sensitive secrets), and automatic token refresh/session expiration on 401.
class ApiInterceptor extends QueuedInterceptor {
  ApiInterceptor({
    required ISecureStorageService storageService,
    required Dio dio,
    void Function()? onSessionExpired,
  }) : _storageService = storageService,
       _dio = dio,
       _onSessionExpired = onSessionExpired;

  final ISecureStorageService _storageService;
  final Dio _dio;
  final void Function()? _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Only attach authorization header if not already provided and not login endpoint
    final isAuthEndpoint = options.path.contains(ApiConstants.loginEndpoint);
    if (!isAuthEndpoint && !options.headers.containsKey('Authorization')) {
      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    _logRequestSafely(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '[HTTP ${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}',
      name: 'ApiInterceptor',
    );
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final is401 = response?.statusCode == 401;
    final isRefreshEndpoint = err.requestOptions.path.contains(
      ApiConstants.refreshEndpoint,
    );
    final isLoginEndpoint = err.requestOptions.path.contains(
      ApiConstants.loginEndpoint,
    );
    final isAlreadyRetried = err.requestOptions.extra['is_retry'] == true;

    if (is401 && !isRefreshEndpoint && !isLoginEndpoint && !isAlreadyRetried) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        try {
          final newAccessToken = await _storageService.getAccessToken();
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          retryOptions.extra['is_retry'] = true;

          final retryResponse = await _dio.fetch<dynamic>(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // If retry fails, forward error and trigger session expiration
        }
      }

      // If refresh fails or no refresh token, notify session expiration
      await _storageService.clearAuthData();
      _onSessionExpired?.call();
    }

    developer.log(
      '[HTTP ERROR ${response?.statusCode}] ${err.requestOptions.method} ${err.requestOptions.path}',
      name: 'ApiInterceptor',
      error: err.message,
    );

    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Use a clean Dio instance to avoid interceptor recursion
      final cleanDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await cleanDio.post<Map<String, dynamic>>(
        ApiConstants.refreshEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final newAccessToken =
            data['accessToken'] as String? ?? data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _storageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void _logRequestSafely(RequestOptions options) {
    // Redact sensitive headers and request body fields
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    if (sanitizedHeaders.containsKey('Authorization')) {
      sanitizedHeaders['Authorization'] = '[REDACTED]';
    }

    dynamic sanitizedData = options.data;
    if (sanitizedData is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(sanitizedData);
      if (copy.containsKey('password')) copy['password'] = '********';
      if (copy.containsKey('token')) copy['token'] = '[REDACTED]';
      if (copy.containsKey('accessToken')) copy['accessToken'] = '[REDACTED]';
      if (copy.containsKey('refreshToken')) copy['refreshToken'] = '[REDACTED]';
      sanitizedData = copy;
    }

    developer.log(
      '[HTTP REQUEST] ${options.method} ${options.uri}',
      name: 'ApiInterceptor',
    );
  }
}
