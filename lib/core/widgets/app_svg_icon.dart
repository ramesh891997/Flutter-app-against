import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG Icon component supporting scalable vectors with themeable color filters.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon({
    required this.assetPath,
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  /// Path to the SVG asset under `assets/icons/`.
  final String assetPath;

  /// Logical pixel size for width and height.
  final double size;

  /// Optional icon tint color. When null, uses the SVG's intrinsic colors.
  final Color? color;

  /// Accessibility semantic label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
