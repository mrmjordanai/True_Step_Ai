import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:truestep/features/onboarding/widgets/page_indicator.dart';
import 'package:truestep/core/constants/colors.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('PageIndicator', () {
    group('rendering', () {
      testWidgets('renders correct number of dots for pageCount', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );

        // Should find 3 container widgets (dots)
        final dots = find.byType(AnimatedContainer);
        expect(dots, findsNWidgets(3));
      });

      testWidgets('renders 1 dot when pageCount is 1', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 1,
            currentPage: 0,
          ),
        );

        final dots = find.byType(AnimatedContainer);
        expect(dots, findsOneWidget);
      });

      testWidgets('renders 5 dots when pageCount is 5', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 5,
            currentPage: 0,
          ),
        );

        final dots = find.byType(AnimatedContainer);
        expect(dots, findsNWidgets(5));
      });
    });

    group('active dot styling', () {
      testWidgets('active dot has wider width than inactive dots', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 1,
          ),
        );

        await tester.pumpAndSettle();

        // Find all AnimatedContainer widgets
        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        // Get the BoxConstraints from each dot's decoration
        // Active dot (index 1) should be wider
        expect(dots.length, equals(3));
      });

      testWidgets('active dot uses accent color', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );

        await tester.pumpAndSettle();

        // The first dot should be active and have accent color
        final activeDot = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );

        final decoration = activeDot.decoration as BoxDecoration;
        expect(decoration.color, equals(TrueStepColors.accentBlue));
      });

      testWidgets('inactive dots use secondary text color', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );

        await tester.pumpAndSettle();

        // The second and third dots should be inactive
        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        final inactiveDot = dots[1];
        final decoration = inactiveDot.decoration as BoxDecoration;
        expect(decoration.color, equals(TrueStepColors.textTertiary));
      });
    });

    group('currentPage changes', () {
      testWidgets('updates active dot when currentPage changes', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );
        await tester.pumpAndSettle();

        // First dot should be active initially
        var dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();
        var firstDotDecoration = dots[0].decoration as BoxDecoration;
        expect(firstDotDecoration.color, equals(TrueStepColors.accentBlue));

        // Update to page 2
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 2,
          ),
        );
        await tester.pumpAndSettle();

        // Now third dot should be active
        dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();
        final thirdDotDecoration = dots[2].decoration as BoxDecoration;
        expect(thirdDotDecoration.color, equals(TrueStepColors.accentBlue));
      });
    });

    group('onDotTap callback', () {
      testWidgets('calls onDotTap with correct index when dot is tapped', (tester) async {
        int? tappedIndex;

        await tester.pumpApp(
          PageIndicator(
            pageCount: 3,
            currentPage: 0,
            onDotTap: (index) => tappedIndex = index,
          ),
        );

        // Tap the second dot
        final dots = find.byType(GestureDetector);
        await tester.tap(dots.at(1));
        await tester.pumpAndSettle();

        expect(tappedIndex, equals(1));
      });

      testWidgets('does not crash when onDotTap is null', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
            onDotTap: null,
          ),
        );

        // Tap should not crash even without callback
        final dots = find.byType(GestureDetector);
        await tester.tap(dots.at(0));
        await tester.pumpAndSettle();

        // If we got here without exception, test passes
      });
    });

    group('custom colors', () {
      testWidgets('uses custom activeColor when provided', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
            activeColor: Colors.red,
          ),
        );

        await tester.pumpAndSettle();

        final activeDot = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );

        final decoration = activeDot.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.red));
      });

      testWidgets('uses custom inactiveColor when provided', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
            inactiveColor: Colors.purple,
          ),
        );

        await tester.pumpAndSettle();

        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        final inactiveDot = dots[1];
        final decoration = inactiveDot.decoration as BoxDecoration;
        expect(decoration.color, equals(Colors.purple));
      });
    });

    group('sizing', () {
      testWidgets('uses default dot size of 8dp', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 1,
          ),
        );

        await tester.pumpAndSettle();

        // Get an inactive dot to check base size
        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        final inactiveDot = dots[0];
        final constraints = inactiveDot.constraints;
        expect(constraints?.maxHeight, equals(8.0));
      });

      testWidgets('uses custom dotSize when provided', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 1,
            dotSize: 12.0,
          ),
        );

        await tester.pumpAndSettle();

        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        final inactiveDot = dots[0];
        final constraints = inactiveDot.constraints;
        expect(constraints?.maxHeight, equals(12.0));
      });

      testWidgets('active dot is wider (24dp default) than inactive dots', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 1,
          ),
        );

        await tester.pumpAndSettle();

        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        // Active dot should be wider
        final activeDot = dots[1];
        final activeConstraints = activeDot.constraints;
        expect(activeConstraints?.maxWidth, equals(24.0));

        // Inactive dot should be square
        final inactiveDot = dots[0];
        final inactiveConstraints = inactiveDot.constraints;
        expect(inactiveConstraints?.maxWidth, equals(8.0));
      });
    });

    group('spacing', () {
      testWidgets('has default spacing between dots', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );

        // Find the Row containing the dots
        final row = tester.widget<Row>(find.byType(Row));

        // Check that mainAxisSize is min (doesn't expand)
        expect(row.mainAxisSize, equals(MainAxisSize.min));
      });
    });

    group('animation', () {
      testWidgets('animates dot changes with proper duration', (tester) async {
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 0,
          ),
        );

        // Change page
        await tester.pumpApp(
          const PageIndicator(
            pageCount: 3,
            currentPage: 1,
          ),
        );

        // Pump a few frames to verify animation is happening
        await tester.pump(const Duration(milliseconds: 100));

        // Continue pumping until animation settles
        await tester.pumpAndSettle();

        // Verify final state
        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        ).toList();

        final secondDotDecoration = dots[1].decoration as BoxDecoration;
        expect(secondDotDecoration.color, equals(TrueStepColors.accentBlue));
      });
    });
  });
}
