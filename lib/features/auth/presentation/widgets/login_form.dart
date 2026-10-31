import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/core/utils/validators.dart';
import 'package:flutter_demo_app/core/widgets/app_button.dart';
import 'package:flutter_demo_app/core/widgets/app_text_field.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Form component handling username and password input, real-time validation, and submission.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillTestCredentials() {
    setState(() {
      _usernameController.text = 'emilys';
      _passwordController.text = 'emilyspass';
    });
    if (_submitted) {
      _formKey.currentState?.validate();
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _submitted = true;
    });

    // Clear any previous error
    ref.read(authProvider.notifier).clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Dismiss soft keyboard
    FocusScope.of(context).unfocus();

    await ref
        .read(authProvider.notifier)
        .login(
          username: _usernameController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final l10n = AppLocalizations.of(context);

    // Listen for auth failure and surface in a floating toast / SnackBar
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Form(
      key: _formKey,
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Field
          AppTextField(
            controller: _usernameController,
            labelText: l10n.usernameLabel,
            hintText: l10n.usernameHint,
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            validator: (value) => Validators.validateUsername(value, l10n),
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          AppTextField(
            controller: _passwordController,
            labelText: l10n.passwordLabel,
            hintText: l10n.passwordHint,
            isPassword: true,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            validator: (value) => Validators.validatePassword(value, l10n),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(),
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sign In Button
          AppButton(
            text: l10n.signIn,
            isLoading: isLoading,
            onPressed: _handleSubmit,
          ),
          const SizedBox(height: AppSpacing.md),

          // Test Credentials Chip / Helper
          Center(
            child: TextButton.icon(
              onPressed: isLoading ? null : _fillTestCredentials,
              icon: const Icon(Icons.key_outlined, size: 16),
              label: Text(l10n.useDemoCredentials),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
