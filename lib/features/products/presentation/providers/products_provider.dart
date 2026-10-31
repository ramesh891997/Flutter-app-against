import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/core/constants/api_constants.dart';
import 'package:flutter_demo_app/core/errors/failure.dart';
import 'package:flutter_demo_app/core/network/dio_client.dart';
import 'package:flutter_demo_app/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_demo_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_demo_app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Status of the products catalog collection.
enum ProductsStatus { initial, loading, loaded, error }

/// Immutable state representation for the paginated product catalog.
class ProductsState {
  const ProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
    required this.skip,
    required this.limit,
    this.total = 0,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.paginationErrorMessage,
  });

  const ProductsState.initial()
    : status = ProductsStatus.initial,
      products = const [],
      hasMore = true,
      skip = 0,
      limit = ApiConstants.defaultPageLimit,
      total = 0,
      isLoadingMore = false,
      isRefreshing = false,
      errorMessage = null,
      paginationErrorMessage = null;

  final ProductsStatus status;
  final List<Product> products;
  final bool hasMore;
  final int skip;
  final int limit;
  final int total;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;
  final String? paginationErrorMessage;

  bool get isInitialLoading => status == ProductsStatus.loading;
  bool get isLoaded => status == ProductsStatus.loaded;
  bool get hasError => status == ProductsStatus.error;
  bool get isEmpty => isLoaded && products.isEmpty;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    bool? hasMore,
    int? skip,
    int? limit,
    int? total,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    String? paginationErrorMessage,
    bool clearErrorMessage = false,
    bool clearPaginationError = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      paginationErrorMessage: clearPaginationError
          ? null
          : (paginationErrorMessage ?? this.paginationErrorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductsState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          products.length == other.products.length &&
          hasMore == other.hasMore &&
          skip == other.skip &&
          limit == other.limit &&
          total == other.total &&
          isLoadingMore == other.isLoadingMore &&
          isRefreshing == other.isRefreshing &&
          errorMessage == other.errorMessage &&
          paginationErrorMessage == other.paginationErrorMessage;

  @override
  int get hashCode => Object.hash(
    status,
    products.length,
    hasMore,
    skip,
    limit,
    total,
    isLoadingMore,
    isRefreshing,
    errorMessage,
    paginationErrorMessage,
  );
}

// ---------------------------------------------------------------------------
// Dependency Injection Providers
// ---------------------------------------------------------------------------

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return ProductRemoteDataSourceImpl(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsUseCase(repository);
});

// ---------------------------------------------------------------------------
// Products Notifier
// ---------------------------------------------------------------------------

class ProductsNotifier extends StateNotifier<ProductsState> {
  ProductsNotifier(this._getProductsUseCase)
    : super(const ProductsState.initial());

  final GetProductsUseCase _getProductsUseCase;

  /// Loads the first page of products.
  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;

    state = state.copyWith(
      status: ProductsStatus.loading,
      clearErrorMessage: true,
      clearPaginationError: true,
    );

    try {
      final result = await _getProductsUseCase(limit: state.limit, skip: 0);

      state = state.copyWith(
        status: ProductsStatus.loaded,
        products: result.products,
        hasMore: result.hasMore,
        skip: result.products.length,
        total: result.total,
        clearErrorMessage: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        status: ProductsStatus.error,
        errorMessage: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: ProductsStatus.error,
        errorMessage: AppLocalizations.defaultLoadProductsError,
      );
    }
  }

  /// Loads the subsequent page of products.
  /// Prevents duplicate calls, detects end of list, and preserves loaded items if request fails.
  Future<void> loadMore() async {
    // Prevent duplicate requests and do not fetch if at the end of the list
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.isRefreshing ||
        state.status != ProductsStatus.loaded) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, clearPaginationError: true);

    try {
      final result = await _getProductsUseCase(
        limit: state.limit,
        skip: state.skip,
      );

      // Append new products, avoiding any accidental duplicates by ID
      final existingIds = state.products.map((p) => p.id).toSet();
      final newUniqueProducts = result.products
          .where((p) => !existingIds.contains(p.id))
          .toList();

      state = state.copyWith(
        products: [...state.products, ...newUniqueProducts],
        hasMore: result.hasMore,
        skip: state.skip + result.products.length,
        total: result.total,
        isLoadingMore: false,
        clearPaginationError: true,
      );
    } on Failure catch (failure) {
      // Preserve existing products on failure
      state = state.copyWith(
        isLoadingMore: false,
        paginationErrorMessage: failure.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
        paginationErrorMessage: AppLocalizations.defaultFailedToLoadMore,
      );
    }
  }

  /// Refreshes the list from page 0.
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(
      isRefreshing: true,
      clearErrorMessage: true,
      clearPaginationError: true,
    );

    try {
      final result = await _getProductsUseCase(limit: state.limit, skip: 0);

      state = state.copyWith(
        status: ProductsStatus.loaded,
        products: result.products,
        hasMore: result.hasMore,
        skip: result.products.length,
        total: result.total,
        isRefreshing: false,
      );
    } on Failure catch (failure) {
      // If refresh failed but we already had products, keep them and surface error
      if (state.products.isNotEmpty) {
        state = state.copyWith(
          isRefreshing: false,
          paginationErrorMessage: failure.message,
        );
      } else {
        state = state.copyWith(
          status: ProductsStatus.error,
          isRefreshing: false,
          errorMessage: failure.message,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: AppLocalizations.defaultRefreshFailed,
      );
    }
  }

  /// Clears any transient pagination error after it has been displayed to user.
  void clearPaginationError() {
    state = state.copyWith(clearPaginationError: true);
  }
}

/// Global ProductsNotifier provider.
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
    return ProductsNotifier(getProductsUseCase);
  },
);
