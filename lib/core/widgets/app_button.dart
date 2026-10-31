import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';

/// Standardized action button supporting elevated and outlined styles with loading states.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.height = 48.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final childContent = isLoading
        ? AppLoader(
            size: 20,
            strokeWidth: 2.5,
            color: isOutlined ? AppColors.primary : Colors.white,
            centered: false,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: effectiveOnPressed,
          child: childContent,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: effectiveOnPressed,
        child: childContent,
      ),
    );
  }
}
