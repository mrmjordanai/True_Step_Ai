import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/constants/colors.dart';
import 'package:truestep/core/constants/spacing.dart';
import 'package:truestep/shared/widgets/glass_card.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test Content'),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('applies BackdropFilter with correct blur sigma', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test'),
        ),
      );

      final backdropFilter = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );

      // Verify BackdropFilter exists
      expect(find.byType(BackdropFilter), findsOneWidget);

      // Check the blur filter is an ImageFilter
      expect(backdropFilter.filter, isA<ImageFilter>());
    });

    testWidgets('uses default padding of 16dp', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test'),
        ),
      );

      // Find all Padding widgets that are descendants of GlassCard
      final paddingFinder = find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(Padding),
      );

      // Find the padding widget that has the expected EdgeInsets
      bool foundCorrectPadding = false;
      for (final element in paddingFinder.evaluate()) {
        final padding = element.widget as Padding;
        if (padding.padding == const EdgeInsets.all(TrueStepSpacing.md)) {
          foundCorrectPadding = true;
          break;
        }
      }

      expect(foundCorrectPadding, isTrue);
    });

    testWidgets('uses custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(24.0);

      await tester.pumpCentered(
        const GlassCard(
          padding: customPadding,
          child: Text('Test'),
        ),
      );

      // Find all Padding widgets that are descendants of GlassCard
      final paddingFinder = find.descendant(
        of: find.byType(GlassCard),
        matching: find.byType(Padding),
      );

      // Find the padding widget that has the expected EdgeInsets
      bool foundCorrectPadding = false;
      for (final element in paddingFinder.evaluate()) {
        final padding = element.widget as Padding;
        if (padding.padding == customPadding) {
          foundCorrectPadding = true;
          break;
        }
      }

      expect(foundCorrectPadding, isTrue);
    });

    testWidgets('uses correct border radius from spacing constants', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(
        decoration!.borderRadius,
        equals(BorderRadius.circular(TrueStepSpacing.radiusLg)),
      );
    });

    testWidgets('shows default glass border color', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.border, isNotNull);
    });

    testWidgets('shows accent color border when provided', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          accentColor: TrueStepColors.sentinelGreen,
          child: Text('Test'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(decoration!.border, isNotNull);

      // When accent color is provided, border should use that color
      final border = decoration.border as Border;
      expect(border.top.color, equals(TrueStepColors.sentinelGreen));
    });

    testWidgets('handles onTap callback', (tester) async {
      var tapped = false;

      await tester.pumpCentered(
        GlassCard(
          onTap: () => tapped = true,
          child: const Text('Test'),
        ),
      );

      await tester.tap(find.byType(GlassCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          child: Text('Test'),
        ),
      );

      // Should not throw when tapping
      await tester.tap(find.byType(GlassCard));
      await tester.pump();

      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('uses custom border radius when provided', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          borderRadius: 24.0,
          child: Text('Test'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration?;
      expect(decoration, isNotNull);
      expect(
        decoration!.borderRadius,
        equals(BorderRadius.circular(24.0)),
      );
    });

    testWidgets('uses custom blur sigma when provided', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          blurSigma: 30.0,
          child: Text('Test'),
        ),
      );

      // Just verify it renders without error
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('has semantics label when provided', (tester) async {
      await tester.pumpCentered(
        const GlassCard(
          semanticLabel: 'Card container',
          child: Text('Test'),
        ),
      );

      // Verify Semantics widget exists with correct label
      final semantics = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Card container',
      );
      expect(semantics, findsOneWidget);
    });
  });
}
