import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/widgets/app_error_view.dart';

void main() {
  group('AppErrorView Widget Tests', () {
    testWidgets('renders title, message and triggers onRetry when tapped', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              title: 'Connection Lost',
              message: 'Check your WiFi and try again.',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Connection Lost'), findsOneWidget);
      expect(find.text('Check your WiFi and try again.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });
  });
}
