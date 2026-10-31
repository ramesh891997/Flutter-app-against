import 'package:dio/dio.dart';

import 'package:flutter_demo_app/core/constants/api_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/network/network_exceptions.dart';
import 'package:flutter_demo_app/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Contract for remote authentication operations.
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> getCurrentUser();
}

/// Concrete implementation communicating with the DummyJSON REST API via Dio.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.loginEndpoint,
        data: {
          ApiConstants.paramUsername: username,
          ApiConstants.paramPassword: password,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const DataParsingException(
          message: AppLocalizations.defaultEmptyResponseBody,
        );
      }

      return AuthResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException(
        message: AppLocalizations.defaultLoginUnexpectedError,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.meEndpoint,
      );

      final data = response.data;
      if (data == null) {
        throw const DataParsingException(
          message: AppLocalizations.defaultEmptyResponseBody,
        );
      }

      return data;
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException(
        message: AppLocalizations.defaultUnknownError,
      );
    }
  }
}
