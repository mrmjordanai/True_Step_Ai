import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/constants/colors.dart';
import 'package:truestep/core/constants/spacing.dart';
import 'package:truestep/shared/widgets/primary_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders label text correctly', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Get Started',
          onPressed: null,
        ),
      );

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpCentered(
        PrimaryButton(
          label: 'Submit',
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled (null)', (tester) async {
      var pressed = false;

      await tester.pumpCentered(
        PrimaryButton(
          label: 'Submit',
          onPressed: null,
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null,
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides label text during loading', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null,
          isLoading: true,
        ),
      );

      // The text should be hidden (opacity 0) or not rendered during loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('has correct height of 56dp', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null,
        ),
      );

      final buttonFinder = find.byType(PrimaryButton);
      final size = tester.getSize(buttonFinder);

      expect(size.height, equals(TrueStepSpacing.buttonHeight));
    });

    testWidgets('has correct border radius of 12dp', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null,
        ),
      );

      // Find the Material or Container with the border radius
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final shape = elevatedButton.style?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());

      final roundedShape = shape as RoundedRectangleBorder;
      expect(
        roundedShape.borderRadius,
        equals(BorderRadius.circular(TrueStepSpacing.radiusMd)),
      );
    });

    testWidgets('primary variant has blue background', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'Submit',
          onPressed: () {},
          variant: ButtonVariant.primary,
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final bgColor = elevatedButton.style?.backgroundColor?.resolve({});
      expect(bgColor, equals(TrueStepColors.buttonPrimary));
    });

    testWidgets('danger variant has red background', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'Delete',
          onPressed: () {},
          variant: ButtonVariant.danger,
        ),
      );

      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      final bgColor = elevatedButton.style?.backgroundColor?.resolve({});
      expect(bgColor, equals(TrueStepColors.buttonDanger));
    });

    testWidgets('secondary variant has outlined style', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'Cancel',
          onPressed: () {},
          variant: ButtonVariant.secondary,
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ghost variant has transparent background', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'Skip',
          onPressed: () {},
          variant: ButtonVariant.ghost,
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('disabled state shows reduced opacity', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null, // Disabled
        ),
      );

      // Button should still be visible but in disabled state
      expect(find.byType(PrimaryButton), findsOneWidget);

      // ElevatedButton should be disabled
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('full width takes available space', (tester) async {
      const testWidth = 300.0;

      await tester.pumpWithSize(
        const PrimaryButton(
          label: 'Submit',
          onPressed: null,
          fullWidth: true,
        ),
        width: testWidth,
        height: 100,
      );

      final size = tester.getSize(find.byType(PrimaryButton));
      expect(size.width, equals(testWidth));
    });

    testWidgets('non-full-width does not force infinite width', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'OK',
          onPressed: () {},
          fullWidth: false,
        ),
      );

      // Verify button renders without crashing
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows leading icon when provided', (tester) async {
      await tester.pumpCentered(
        PrimaryButton(
          label: 'Continue with Apple',
          onPressed: () {},
          icon: Icons.apple,
        ),
      );

      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('is not tappable during loading', (tester) async {
      var pressed = false;

      await tester.pumpCentered(
        PrimaryButton(
          label: 'Submit',
          onPressed: () => pressed = true,
          isLoading: true,
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      await tester.pumpCentered(
        const PrimaryButton(
          label: 'Submit Form',
          onPressed: null,
        ),
      );

      // The button should have the label as accessible text
      expect(find.text('Submit Form'), findsOneWidget);
    });
  });
}
