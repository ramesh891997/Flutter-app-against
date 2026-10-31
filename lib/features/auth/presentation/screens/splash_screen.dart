import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo_app/app/router/route_names.dart';
import 'package:flutter_demo_app/app/theme/app_colors.dart';
import 'package:flutter_demo_app/app/theme/app_spacing.dart';
import 'package:flutter_demo_app/app/theme/app_text_styles.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/l10n/app_localizations.dart';

/// Splash screen displayed on initial launch with an elegant entrance animation for the store brand.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _minDisplayTimer;
  bool _minDisplayElapsed = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Configure entrance animation for the Store brand name
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();

    // Trigger session restoration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).restoreSession();
    });

    // Minimum display duration before navigating
    _minDisplayTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _minDisplayElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _minDisplayTimer?.cancel();
    super.dispose();
  }

  void _checkAndNavigate() {
    if (!_minDisplayElapsed) return;

    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.authenticated) {
      context.goNamed(RouteNames.products);
    } else if (authState.status == AuthStatus.unauthenticated ||
        authState.status == AuthStatus.error) {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      _checkAndNavigate();
    });

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Store Brand Name
            SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Text(
                    l10n.appName,
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Tagline fading in
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(l10n.tagline, style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Spinner
            const AppLoader(size: 28, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
