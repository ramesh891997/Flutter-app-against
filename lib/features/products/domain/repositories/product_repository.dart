import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';

/// Contract for product catalog data operations in the domain layer.
abstract class ProductRepository {
  /// Fetches a paginated page of products.
  Future<PaginatedProducts> getProducts({
    required int limit,
    required int skip,
  });

  /// Fetches a single product's detailed information by id.
  Future<Product> getProductDetails(int id);
}
