import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/core/widgets/app_shimmer.dart';

/// Skeleton card matching the dimensions and layout of [ProductCard].
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            ShimmerBox(
              width: 96,
              height: 96,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            SizedBox(width: AppSpacing.md),

            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating Row
                  Row(
                    children: [
                      ShimmerBox(width: 64, height: 16),
                      Spacer(),
                      ShimmerBox(width: 36, height: 16),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),

                  // Title placeholder
                  ShimmerBox(width: 160, height: 16),
                  SizedBox(height: 6),

                  // Description line 1
                  ShimmerBox(width: double.infinity, height: 12),
                  SizedBox(height: 4),

                  // Description line 2
                  ShimmerBox(width: 120, height: 12),
                  SizedBox(height: AppSpacing.sm),

                  // Price placeholder
                  Row(
                    children: [
                      ShimmerBox(width: 72, height: 18),
                      SizedBox(width: AppSpacing.sm),
                      ShimmerBox(width: 48, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton list displayed during initial catalog data loading.
class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: AppSpacing.paddingMd,
        itemCount: itemCount,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      ),
    );
  }
}
