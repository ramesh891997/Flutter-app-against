import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/product_details_provider.dart';

class MockGetProductDetailsUseCase extends Mock
    implements GetProductDetailsUseCase {}

void main() {
  late MockGetProductDetailsUseCase mockGetProductDetailsUseCase;

  const tProduct = Product(
    id: 1,
    title: 'Essence Mascara',
    description: 'High quality lash princess mascara.',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 10.0,
    rating: 4.8,
    stock: 25,
    tags: ['beauty'],
    images: ['https://example.com/img1.jpg'],
    thumbnail: 'https://example.com/thumb.jpg',
    brand: 'Essence',
  );

  setUp(() {
    mockGetProductDetailsUseCase = MockGetProductDetailsUseCase();
  });

  group('productDetailsProvider', () {
    test('loads product details successfully', () async {
      when(
        () => mockGetProductDetailsUseCase(1),
      ).thenAnswer((_) async => tProduct);

      final container = ProviderContainer(
        overrides: [
          getProductDetailsUseCaseProvider.overrideWithValue(
            mockGetProductDetailsUseCase,
          ),
        ],
      );
      addTearDown(container.dispose);

      final asyncValue = await container.read(productDetailsProvider(1).future);

      expect(asyncValue.id, 1);
      expect(asyncValue.title, 'Essence Mascara');
      expect(asyncValue.brand, 'Essence');
      verify(() => mockGetProductDetailsUseCase(1)).called(1);
    });

    test('yields AsyncError on failure', () async {
      when(
        () => mockGetProductDetailsUseCase(999),
      ).thenThrow(const ServerFailure(message: 'Product not found'));

      final container = ProviderContainer(
        overrides: [
          getProductDetailsUseCaseProvider.overrideWithValue(
            mockGetProductDetailsUseCase,
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(productDetailsProvider(999).future),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
