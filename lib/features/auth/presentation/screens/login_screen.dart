import 'package:flutter/material.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Screen displaying the authentication interface.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title & Tagline
                    Text(
                      l10n.appName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Card
                    Card(
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.signIn, style: AppTextStyles.titleLarge),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.enterCredentials,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const LoginForm(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
