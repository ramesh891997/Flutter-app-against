import 'package:flutter_demo_app/features/products/domain/entities/product.dart';

/// Domain entity representing a paginated response of products.
class PaginatedProducts {
  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  /// Returns true if there are more products available to load on subsequent pages.
  bool get hasMore => (skip + products.length) < total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedProducts &&
          runtimeType == other.runtimeType &&
          total == other.total &&
          skip == other.skip &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(total, skip, limit);
}
