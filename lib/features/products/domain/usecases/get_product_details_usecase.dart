import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/repositories/product_repository.dart';

/// Use case to retrieve single product details.
class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(int id) {
    return _repository.getProductDetails(id);
  }
}
