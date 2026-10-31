import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';

/// Standardized loading indicator used throughout StoreFlow.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 28.0,
    this.strokeWidth = 3.0,
    this.color,
    this.centered = true,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );

    if (centered) {
      return Center(child: indicator);
    }
    return indicator;
  }
}
