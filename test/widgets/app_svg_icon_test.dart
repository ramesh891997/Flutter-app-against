import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo_app/core/constants/asset_constants.dart';
import 'package:flutter_demo_app/core/widgets/app_svg_icon.dart';

void main() {
  group('AppSvgIcon Widget Tests', () {
    testWidgets(
      'renders SvgPicture.asset with proper size, color filter, and semantics',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AppSvgIcon(
                assetPath: AssetConstants.backIcon,
                size: 32,
                color: Colors.red,
                semanticLabel: 'Back button',
              ),
            ),
          ),
        );

        final svgFinder = find.byType(SvgPicture);
        expect(svgFinder, findsOneWidget);

        final svgWidget = tester.widget<SvgPicture>(svgFinder);
        expect(svgWidget.width, 32);
        expect(svgWidget.height, 32);
        expect(svgWidget.semanticsLabel, 'Back button');
        expect(
          svgWidget.colorFilter,
          const ColorFilter.mode(Colors.red, BlendMode.srcIn),
        );
      },
    );
  });
}
