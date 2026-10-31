import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/utils/formatters.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';
import 'package:flutter_demo_app/features/products/presentation/widgets/product_image.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Card displaying product thumbnail, title, pricing, rating, and category.
class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onTap, super.key});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Product Thumbnail
              Hero(
                tag: 'product-image-${product.id}',
                child: ProductImage(
                  imageUrl: product.primaryImageUrl,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Product Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          Formatters.formatRating(product.rating),
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Title
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),

                    // Description Preview
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Price & Stock Status
                    Row(
                      children: [
                        Text(
                          Formatters.formatCurrency(product.price),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            Formatters.formatDiscount(
                              product.discountPercentage,
                              l10n,
                            ),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (!product.isInStock)
                          Text(
                            l10n.outOfStock,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
