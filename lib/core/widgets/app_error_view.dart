import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/constants/asset_constants.dart';
import 'package:flutter_demo_app/core/widgets/app_button.dart';
import 'package:flutter_demo_app/core/widgets/app_svg_icon.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Reusable full-view error state with message, SVG illustration, and retry action.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.message,
    super.key,
    this.title,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveTitle = title ?? l10n.oopsSomethingWentWrong;
    final effectiveRetryLabel = retryLabel ?? l10n.tryAgain;

    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: AppSvgIcon(
                assetPath: AssetConstants.errorIcon,
                size: 48,
                color: AppColors.error,
                semanticLabel: l10n.errorIcon,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
                child: AppButton(
                  text: effectiveRetryLabel,
                  onPressed: onRetry,
                  icon: const AppSvgIcon(
                    assetPath: AssetConstants.refreshIcon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
