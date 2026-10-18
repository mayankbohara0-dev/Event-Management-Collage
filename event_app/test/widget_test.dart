import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest_app/core/theme/app_colors.dart';
import 'package:zest_app/core/theme/app_theme.dart';
import 'package:zest_app/core/widgets/zest_button.dart';
import 'package:zest_app/core/widgets/zest_logo.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('ZestColors theme extension is provided on light and dark themes', () {
    final lightZest = AppTheme.light.extension<ZestColors>();
    final darkZest = AppTheme.dark.extension<ZestColors>();

    expect(lightZest, isNotNull);
    expect(lightZest!.lime, equals(AppColors.lime));
    expect(lightZest.ink, equals(AppColors.ink));

    expect(darkZest, isNotNull);
    expect(darkZest!.lime, equals(AppColors.lime));
    expect(darkZest.ink, equals(AppColors.ink));
  });

  testWidgets('ZestButton renders label and triggers onPressed callback', (tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ZestButton(
            label: 'Claim Pass 🎟️',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Claim Pass 🎟️'), findsOneWidget);
    await tester.tap(find.text('Claim Pass 🎟️'));
    expect(pressed, isTrue);
  });

  testWidgets('ZestLogo variants instantiate and render without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              ZestLogo.icon(size: 64),
              ZestLogo.markSmall(size: 40),
              ZestLogo.wordmark(height: 24),
              ZestLogo.lockup(height: 36),
              ZestLogo.watermark(size: 100),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(ZestLogo), findsNWidgets(5));
  });
}
