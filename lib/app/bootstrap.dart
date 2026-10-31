import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_demo_app/app/app.dart';
import 'package:flutter_demo_app/core/network/session_expired_provider.dart';
import 'package:flutter_demo_app/features/auth/presentation/providers/auth_provider.dart';

/// Initializes core services and boots the Flutter application with ProviderScope.
Future<void> bootstrap() async {
  // Ensure framework bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        sessionExpiredProvider.overrideWith(
          (ref) => () {
            ref.read(authProvider.notifier).handleSessionExpired();
          },
        ),
      ],
      child: const ProductApp(),
    ),
  );
}
