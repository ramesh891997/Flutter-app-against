import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Concrete implementation of [ProductRepository] handling data mapping and error transformation.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remoteDataSource);

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<PaginatedProducts> getProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
      );
      return responseModel.toEntity();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (_) {
      throw const UnknownFailure(
        message: AppLocalizations.defaultFetchProductsFailed,
      );
    }
  }

  @override
  Future<Product> getProductDetails(int id) async {
    try {
      final model = await _remoteDataSource.getProductDetails(id);
      return model.toEntity();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (_) {
      throw const UnknownFailure(
        message: AppLocalizations.defaultFetchProductDetailsFailed,
      );
    }
  }
}
