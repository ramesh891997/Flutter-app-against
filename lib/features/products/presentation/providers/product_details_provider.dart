import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/products_provider.dart';

final getProductDetailsUseCaseProvider = Provider<GetProductDetailsUseCase>((
  ref,
) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductDetailsUseCase(repository);
});

/// Future provider family for retrieving details of a single product.
final productDetailsProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  productId,
) async {
  final getDetailsUseCase = ref.watch(getProductDetailsUseCaseProvider);
  return getDetailsUseCase(productId);
});
