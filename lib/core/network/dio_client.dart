import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/core/constants/api_constants.dart';
import 'package:flutter_demo_app/core/network/api_interceptor.dart';
import 'package:flutter_demo_app/core/network/session_expired_provider.dart';
import 'package:flutter_demo_app/core/storage/secure_storage_service.dart';

/// Provider supplying the configured singleton [Dio] client for network requests.
final dioClientProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(secureStorageServiceProvider);
  final onSessionExpired = ref.watch(sessionExpiredProvider);

  final baseOptions = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    sendTimeout: ApiConstants.sendTimeout,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    responseType: ResponseType.json,
  );

  final dio = Dio(baseOptions);

  dio.interceptors.add(
    ApiInterceptor(
      storageService: storageService,
      dio: dio,
      onSessionExpired: onSessionExpired,
    ),
  );

  return dio;
});
