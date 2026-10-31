import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/products_provider.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late ProductsNotifier productsNotifier;

  Product createProduct(int id) {
    return Product(
      id: id,
      title: 'Product $id',
      description: 'Desc $id',
      category: 'general',
      price: 10.0 * id,
      discountPercentage: 0,
      rating: 4.0,
      stock: 10,
      tags: const [],
      images: const [],
      thumbnail: '',
    );
  }

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    productsNotifier = ProductsNotifier(mockGetProductsUseCase);
  });

  group('ProductsNotifier', () {
    test('initial state has empty products and initial status', () {
      expect(productsNotifier.state.status, ProductsStatus.initial);
      expect(productsNotifier.state.products, isEmpty);
      expect(productsNotifier.state.hasMore, isTrue);
    });

    test('loadInitial loads page 0 and updates state to loaded', () async {
      final tProducts = [createProduct(1), createProduct(2)];
      when(
        () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
      ).thenAnswer(
        (_) async => PaginatedProducts(
          products: tProducts,
          total: 20,
          skip: 0,
          limit: 15,
        ),
      );

      await productsNotifier.loadInitial();

      expect(productsNotifier.state.status, ProductsStatus.loaded);
      expect(productsNotifier.state.products.length, 2);
      expect(productsNotifier.state.hasMore, isTrue);
      expect(productsNotifier.state.skip, 2);
      expect(productsNotifier.state.total, 20);
    });

    test('loadInitial sets empty state when products list is empty', () async {
      when(
        () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
      ).thenAnswer(
        (_) async =>
            const PaginatedProducts(products: [], total: 0, skip: 0, limit: 15),
      );

      await productsNotifier.loadInitial();

      expect(productsNotifier.state.status, ProductsStatus.loaded);
      expect(productsNotifier.state.isEmpty, isTrue);
      expect(productsNotifier.state.hasMore, isFalse);
    });

    test('loadInitial sets error status on failure', () async {
      when(
        () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
      ).thenThrow(const NetworkFailure(message: 'Network offline'));

      await productsNotifier.loadInitial();

      expect(productsNotifier.state.status, ProductsStatus.error);
      expect(productsNotifier.state.errorMessage, 'Network offline');
      expect(productsNotifier.state.products, isEmpty);
    });

    test(
      'loadMore appends products, updates skip, and preserves previous items',
      () async {
        // Step 1: Initial load
        final page1 = [createProduct(1), createProduct(2)];
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
        ).thenAnswer(
          (_) async =>
              PaginatedProducts(products: page1, total: 4, skip: 0, limit: 2),
        );
        await productsNotifier.loadInitial();

        // Step 2: Load more (page 2)
        final page2 = [createProduct(3), createProduct(4)];
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 2),
        ).thenAnswer(
          (_) async =>
              PaginatedProducts(products: page2, total: 4, skip: 2, limit: 2),
        );
        await productsNotifier.loadMore();

        expect(productsNotifier.state.products.length, 4);
        expect(productsNotifier.state.products.map((p) => p.id), [1, 2, 3, 4]);
        expect(productsNotifier.state.hasMore, isFalse); // Total 4 reached
      },
    );

    test(
      'loadMore preserves already loaded products if subsequent page fails',
      () async {
        // Step 1: Initial load
        final page1 = [createProduct(1), createProduct(2)];
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
        ).thenAnswer(
          (_) async =>
              PaginatedProducts(products: page1, total: 10, skip: 0, limit: 2),
        );
        await productsNotifier.loadInitial();

        // Step 2: Load more fails
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 2),
        ).thenThrow(const NetworkFailure(message: 'Timeout loading page 2'));

        await productsNotifier.loadMore();

        // Products from page 1 must remain intact!
        expect(productsNotifier.state.products.length, 2);
        expect(
          productsNotifier.state.paginationErrorMessage,
          'Timeout loading page 2',
        );
        expect(productsNotifier.state.isLoadingMore, isFalse);
      },
    );

    test(
      'loadMore does not trigger when hasMore is false (end of list detection)',
      () async {
        // Initial load with all items loaded
        final page1 = [createProduct(1)];
        when(
          () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
        ).thenAnswer(
          (_) async =>
              PaginatedProducts(products: page1, total: 1, skip: 0, limit: 15),
        );
        await productsNotifier.loadInitial();
        expect(productsNotifier.state.hasMore, isFalse);

        // Attempt to load more
        await productsNotifier.loadMore();

        // Should not call use case again
        verify(
          () => mockGetProductsUseCase(
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          ),
        ).called(1);
      },
    );

    test('refresh reloads list from skip 0', () async {
      final initialPage = [createProduct(1)];
      when(
        () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
      ).thenAnswer(
        (_) async => PaginatedProducts(
          products: initialPage,
          total: 10,
          skip: 0,
          limit: 15,
        ),
      );
      await productsNotifier.loadInitial();

      final refreshedPage = [createProduct(1), createProduct(2)];
      when(
        () => mockGetProductsUseCase(limit: any(named: 'limit'), skip: 0),
      ).thenAnswer(
        (_) async => PaginatedProducts(
          products: refreshedPage,
          total: 10,
          skip: 0,
          limit: 15,
        ),
      );

      await productsNotifier.refresh();

      expect(productsNotifier.state.products.length, 2);
      expect(productsNotifier.state.isRefreshing, isFalse);
    });
  });
}
