import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/constants/asset_constants.dart';
import 'package:flutter_demo_app/core/widgets/app_button.dart';
import 'package:flutter_demo_app/core/widgets/app_svg_icon.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Reusable empty state view displayed when no data is available.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveTitle = title ?? l10n.noItemsFound;
    final effectiveMessage = message ?? l10n.noItemsMessage;

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
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: AppSvgIcon(
                assetPath: AssetConstants.emptyStateIcon,
                size: 56,
                color: AppColors.primary,
                semanticLabel: l10n.emptyStateIcon,
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
              effectiveMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
                child: AppButton(text: actionLabel!, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
