import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo_app/app/router/route_names.dart';
import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/constants/app_constants.dart';
import 'package:flutter_demo_app/core/constants/asset_constants.dart';
import 'package:flutter_demo_app/core/utils/time_utils.dart';
import 'package:flutter_demo_app/core/widgets/app_empty_view.dart';
import 'package:flutter_demo_app/core/widgets/app_error_view.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';
import 'package:flutter_demo_app/core/widgets/app_svg_icon.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/products_provider.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_card_skeleton.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Screen displaying the paginated product catalog with time-based greetings,
/// shimmer skeleton loading, pull-to-refresh, and infinite scroll.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial load triggered after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= AppConstants.paginationScrollThreshold) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  Future<void> _showLogoutDialog(AppLocalizations l10n) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    // Listen for transient pagination errors and display snackbar
    ref.listen<ProductsState>(productsProvider, (previous, next) {
      if (next.paginationErrorMessage != null &&
          next.paginationErrorMessage != previous?.paginationErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.paginationErrorMessage!),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: l10n.retry,
              textColor: Colors.white,
              onPressed: () {
                ref.read(productsProvider.notifier).loadMore();
              },
            ),
          ),
        );
        ref.read(productsProvider.notifier).clearPaginationError();
      }
    });

    // Time-based global greeting and prominent user name
    final greeting = TimeUtils.getGreeting(l10n);
    final userName =
        authState.session?.firstName ??
        authState.session?.username ??
        l10n.welcome;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              greeting,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              userName,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: AppSvgIcon(
              assetPath: AssetConstants.logoutIcon,
              size: 22,
              color: AppColors.textPrimary,
              semanticLabel: l10n.logoutIcon,
            ),
            onPressed: () => _showLogoutDialog(l10n),
          ),
        ],
      ),
      body: _buildBody(productsState, l10n),
    );
  }

  Widget _buildBody(ProductsState state, AppLocalizations l10n) {
    // 1. Initial Shimmer Skeleton Loading State (replaces circular loader)
    if (state.isInitialLoading) {
      return const ProductListSkeleton();
    }

    // 2. Full Screen Error State
    if (state.hasError && state.products.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? l10n.loadProductsError,
        onRetry: () => ref.read(productsProvider.notifier).loadInitial(),
      );
    }

    // 3. Empty State
    if (state.isEmpty) {
      return AppEmptyView(
        title: l10n.noProductsTitle,
        message: l10n.noProductsMessage,
        actionLabel: l10n.refresh,
        onAction: () => ref.read(productsProvider.notifier).refresh(),
      );
    }

    // 4. Products List with Pull-to-Refresh and Pagination
    return RefreshIndicator(
      onRefresh: () => ref.read(productsProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.paddingMd,
        itemCount: state.products.length + (state.hasMore ? 1 : 1),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          // Bottom loading / end-of-list footer
          if (index == state.products.length) {
            if (state.hasMore) {
              return const Padding(
                padding: AppSpacing.paddingLg,
                child: Center(child: AppLoader(size: 24, strokeWidth: 2.5)),
              );
            }
            return Padding(
              padding: AppSpacing.paddingLg,
              child: Center(
                child: Text(l10n.endOfCatalog, style: AppTextStyles.bodySmall),
              ),
            );
          }

          final product = state.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              context.pushNamed(
                RouteNames.productDetails,
                pathParameters: {'id': product.id.toString()},
              );
            },
          );
        },
      ),
    );
  }
}
