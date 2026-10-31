import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/repositories/product_repository.dart';

/// Use case to retrieve a paginated page of products.
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<PaginatedProducts> call({required int limit, required int skip}) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}
