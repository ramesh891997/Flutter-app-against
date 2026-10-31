import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel & PaginatedProductsResponseModel', () {
    final tProductJson = {
      'id': 1,
      'title': 'Essence Mascara Lash Princess',
      'description': 'A popular volumizing mascara.',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.48,
      'rating': 4.5,
      'stock': 99,
      'tags': ['beauty', 'mascara'],
      'brand': 'Essence',
      'sku': 'BEA-ESS-001',
      'warrantyInformation': '1 week warranty',
      'shippingInformation': 'Ships in 3-5 days',
      'availabilityStatus': 'In Stock',
      'images': ['https://example.com/1.jpg'],
      'thumbnail': 'https://example.com/thumb.jpg',
    };

    final tPaginatedJson = {
      'products': [tProductJson],
      'total': 100,
      'skip': 0,
      'limit': 10,
    };

    test('ProductModel parses JSON correctly', () {
      final model = ProductModel.fromJson(tProductJson);

      expect(model.id, 1);
      expect(model.title, 'Essence Mascara Lash Princess');
      expect(model.price, 9.99);
      expect(model.rating, 4.5);
      expect(model.stock, 99);
      expect(model.brand, 'Essence');
      expect(model.images.length, 1);
      expect(model.thumbnail, 'https://example.com/thumb.jpg');
    });

    test('ProductModel handles nullable and missing fields safely', () {
      final minimalJson = {
        'id': 2,
        'title': 'Minimal Product',
        'price': 15, // integer instead of double
        'rating': 3, // integer instead of double
      };

      final model = ProductModel.fromJson(minimalJson);

      expect(model.id, 2);
      expect(model.title, 'Minimal Product');
      expect(model.price, 15.0);
      expect(model.rating, 3.0);
      expect(model.brand, isNull);
      expect(model.tags, isEmpty);
      expect(model.images, isEmpty);
      expect(model.thumbnail, '');
    });

    test('PaginatedProductsResponseModel parses list and detects hasMore', () {
      final paginatedModel = PaginatedProductsResponseModel.fromJson(
        tPaginatedJson,
      );

      expect(paginatedModel.products.length, 1);
      expect(paginatedModel.total, 100);
      expect(paginatedModel.skip, 0);
      expect(paginatedModel.limit, 10);

      final entity = paginatedModel.toEntity();
      expect(entity.hasMore, isTrue); // (0 + 1) < 100
    });

    test('PaginatedProducts hasMore is false when all products are loaded', () {
      final finishedJson = {
        'products': [tProductJson],
        'total': 1,
        'skip': 0,
        'limit': 10,
      };

      final entity = PaginatedProductsResponseModel.fromJson(
        finishedJson,
      ).toEntity();
      expect(entity.hasMore, isFalse); // (0 + 1) is not < 1
    });
  });
}
