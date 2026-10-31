import 'package:dio/dio.dart';

import 'package:flutter_demo_app/core/constants/api_constants.dart';
import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/network/network_exceptions.dart';
import 'package:flutter_demo_app/features/products/data/models/product_model.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Contract for remote product catalog network operations.
abstract class ProductRemoteDataSource {
  Future<PaginatedProductsResponseModel> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<ProductModel> getProductDetails(int id, {CancelToken? cancelToken});
}

/// Concrete implementation querying DummyJSON products endpoints using Dio.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PaginatedProductsResponseModel> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.productsEndpoint,
        queryParameters: {
          ApiConstants.paramLimit: limit,
          ApiConstants.paramSkip: skip,
        },
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data == null) {
        throw const DataParsingException(
          message: AppLocalizations.defaultEmptyResponseBody,
        );
      }

      return PaginatedProductsResponseModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException(
        message: AppLocalizations.defaultFetchProductsFailed,
      );
    }
  }

  @override
  Future<ProductModel> getProductDetails(
    int id, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.productDetailsEndpoint(id),
        cancelToken: cancelToken,
      );

      final data = response.data;
      if (data == null) {
        throw const DataParsingException(
          message: AppLocalizations.defaultEmptyResponseBody,
        );
      }

      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw NetworkExceptionHandler.handle(e);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException(
        message: AppLocalizations.defaultFetchProductDetailsFailed,
      );
    }
  }
}
