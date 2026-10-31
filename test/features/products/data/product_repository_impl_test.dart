import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/errors/app_exception.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_demo_app/features/products/data/models/product_model.dart';
import 'package:flutter_demo_app/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

void main() {
  late MockProductRemoteDataSource mockDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockDataSource);
  });

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    description: 'Description',
    category: 'beauty',
    price: 19.99,
    discountPercentage: 5.0,
    rating: 4.2,
    stock: 50,
    tags: ['tag1'],
    images: ['https://example.com/image.jpg'],
    thumbnail: 'https://example.com/thumb.jpg',
  );

  const tPaginatedModel = PaginatedProductsResponseModel(
    products: [tProductModel],
    total: 10,
    skip: 0,
    limit: 10,
  );

  group('ProductRepositoryImpl', () {
    test('getProducts returns domain PaginatedProducts on success', () async {
      when(
        () => mockDataSource.getProducts(limit: 10, skip: 0),
      ).thenAnswer((_) async => tPaginatedModel);

      final result = await repository.getProducts(limit: 10, skip: 0);

      expect(result.products.length, 1);
      expect(result.products.first.id, 1);
      expect(result.total, 10);
      verify(() => mockDataSource.getProducts(limit: 10, skip: 0)).called(1);
    });

    test('getProducts maps NetworkException to NetworkFailure', () async {
      when(
        () => mockDataSource.getProducts(limit: 10, skip: 0),
      ).thenThrow(const NetworkException(message: 'No connection'));

      expect(
        () => repository.getProducts(limit: 10, skip: 0),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('getProductDetails returns domain Product on success', () async {
      when(
        () => mockDataSource.getProductDetails(1),
      ).thenAnswer((_) async => tProductModel);

      final product = await repository.getProductDetails(1);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      verify(() => mockDataSource.getProductDetails(1)).called(1);
    });
  });
}
