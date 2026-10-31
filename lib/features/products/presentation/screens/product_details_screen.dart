import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo_app/app/router/route_names.dart';
import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/constants/asset_constants.dart';
import 'package:flutter_demo_app/core/utils/formatters.dart';
import 'package:flutter_demo_app/core/widgets/app_error_view.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';
import 'package:flutter_demo_app/core/widgets/app_svg_icon.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/presentation/providers/product_details_provider.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_image.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Screen displaying exhaustive details for a single selected product.
class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({required this.productId, super.key});

  final int productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.back,
          icon: AppSvgIcon(
            assetPath: AssetConstants.backIcon,
            size: 22,
            color: AppColors.textPrimary,
            semanticLabel: l10n.backButton,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.products);
            }
          },
        ),
        title: Text(l10n.productDetails),
      ),
      body: productAsync.when(
        loading: () => const AppLoader(),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(productDetailsProvider(widget.productId));
          },
        ),
        data: (product) => _buildContent(context, product, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Product product,
    AppLocalizations l10n,
  ) {
    final images = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];
    final activeImageUrl =
        images.isNotEmpty && _selectedImageIndex < images.length
        ? images[_selectedImageIndex]
        : product.thumbnail;

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Main Image
          Center(
            child: Hero(
              tag: 'product-image-${product.id}',
              child: Container(
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ProductImage(
                  imageUrl: activeImageUrl,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.contain,
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Thumbnail Selector Row (if multiple images)
          if (images.length > 1) ...[
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedImageIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: AppSpacing.borderRadiusMd,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ProductImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Category & Stock Status Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  product.category.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.isInStock
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  product.isInStock
                      ? l10n.inStockWithCount(product.stock)
                      : l10n.outOfStock,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: product.isInStock
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(product.title, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.sm),

          // Rating & Brand Row
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                Formatters.formatRating(product.rating),
                style: AppTextStyles.labelLarge,
              ),
              if (product.brand != null && product.brand!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.md),
                const Text('•', style: AppTextStyles.bodyMedium),
                const SizedBox(width: AppSpacing.md),
                Text(
                  l10n.brandPrefix(product.brand!),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Price & Discount Box
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.price, style: AppTextStyles.labelSmall),
                    Text(
                      Formatters.formatCurrency(product.price),
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (product.discountPercentage > 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    child: Text(
                      Formatters.formatDiscount(
                        product.discountPercentage,
                        l10n,
                      ),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description Section
          Text(l10n.description, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(product.description, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.lg),

          // Meta Specs: SKU, Warranty, Shipping (if available)
          if (product.sku != null ||
              product.warrantyInformation != null ||
              product.shippingInformation != null) ...[
            Text(l10n.specifications, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (product.sku != null)
                    _buildSpecRow(l10n.sku, product.sku!),
                  if (product.warrantyInformation != null) ...[
                    const Divider(height: 16),
                    _buildSpecRow(l10n.warranty, product.warrantyInformation!),
                  ],
                  if (product.shippingInformation != null) ...[
                    const Divider(height: 16),
                    _buildSpecRow(l10n.shipping, product.shippingInformation!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
