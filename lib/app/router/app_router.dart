import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_demo_app/app/router/route_names.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_demo_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_demo_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_demo_app/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter_demo_app/features/products/presentation/screens/products_screen.dart';

/// Notifier that triggers GoRouter redirects whenever AuthState mutates.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final location = state.matchedLocation;

    final isSplash = location == RouteNames.splashPath;
    final isLogin = location == RouteNames.loginPath;

    // Allow splash screen to display brand identity and handle initial transition
    if (isSplash) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;

    // Guard protected routes against unauthenticated access
    if (!isAuthenticated) {
      return isLogin ? null : RouteNames.loginPath;
    }

    // Redirect authenticated user away from login
    if (isLogin) {
      return RouteNames.productsPath;
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splashPath,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.productsPath,
        name: RouteNames.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: RouteNames.productDetailsPath,
        name: RouteNames.productDetails,
        builder: (context, state) {
          final idParam = state.pathParameters['id'];
          final id = int.tryParse(idParam ?? '') ?? 0;
          return ProductDetailsScreen(productId: id);
        },
      ),
    ],
  );
});
