import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';

/// Cached network image with loading placeholder and graceful fallback.
class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.borderRadiusMd,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppColors.shimmerBase,
          child: const Center(child: AppLoader(size: 20, strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textMuted,
          size: 28,
        ),
      ),
    );
  }
}
