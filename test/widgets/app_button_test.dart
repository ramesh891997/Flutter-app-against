import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/widgets/app_button.dart';
import 'package:flutter_demo_app/core/widgets/app_loader.dart';

void main() {
  group('AppButton Widget Tests', () {
    testWidgets('renders button text and triggers onPressed when tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'shows loading indicator and ignores tap when isLoading is true',
      (tester) async {
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppButton(
                text: 'Submit',
                isLoading: true,
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.byType(AppLoader), findsOneWidget);
        expect(find.text('Submit'), findsNothing);

        await tester.tap(find.byType(AppLoader));
        expect(tapped, isFalse);
      },
    );

    testWidgets('renders outlined button when isOutlined is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(text: 'Cancel', isOutlined: true, onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
