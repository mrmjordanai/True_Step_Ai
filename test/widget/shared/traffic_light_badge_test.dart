import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/constants/colors.dart';
import 'package:truestep/shared/widgets/traffic_light_badge.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('TrafficLightBadge', () {
    testWidgets('renders green badge for green state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.green),
      );

      expect(find.byType(TrafficLightBadge), findsOneWidget);
    });

    testWidgets('renders yellow badge for yellow state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.yellow),
      );

      expect(find.byType(TrafficLightBadge), findsOneWidget);
    });

    testWidgets('renders red badge for red state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.red),
      );

      expect(find.byType(TrafficLightBadge), findsOneWidget);
    });

    testWidgets('shows eye icon for green state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.green),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows waveform icon for yellow state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.yellow),
      );

      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
    });

    testWidgets('shows stop hand icon for red state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.red),
      );

      expect(find.byIcon(Icons.pan_tool), findsOneWidget);
    });

    testWidgets('displays label text when provided', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          label: 'Watching',
        ),
      );

      expect(find.text('Watching'), findsOneWidget);
    });

    testWidgets('applies glow effect when showGlow is true', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          showGlow: true,
        ),
      );

      // Find a container with box shadow
      final container = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty;
        }
        return false;
      });

      expect(container, findsOneWidget);
    });

    testWidgets('no glow when showGlow is false', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          showGlow: false,
        ),
      );

      // Should not have glowing container
      final glowingContainer = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.boxShadow != null &&
              decoration.boxShadow!.isNotEmpty;
        }
        return false;
      });

      expect(glowingContainer, findsNothing);
    });

    testWidgets('small size has 24dp height', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          size: BadgeSize.small,
        ),
      );

      final size = tester.getSize(find.byType(TrafficLightBadge));
      expect(size.height, equals(24.0));
    });

    testWidgets('medium size has 32dp height', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          size: BadgeSize.medium,
        ),
      );

      final size = tester.getSize(find.byType(TrafficLightBadge));
      expect(size.height, equals(32.0));
    });

    testWidgets('large size has 48dp height', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          size: BadgeSize.large,
        ),
      );

      final size = tester.getSize(find.byType(TrafficLightBadge));
      expect(size.height, equals(48.0));
    });

    testWidgets('has correct color for green state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.green),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.visibility));
      expect(icon.color, equals(TrueStepColors.sentinelGreen));
    });

    testWidgets('has correct color for yellow state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.yellow),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.graphic_eq));
      expect(icon.color, equals(TrueStepColors.analysisYellow));
    });

    testWidgets('has correct color for red state', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(state: TrafficLightState.red),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.pan_tool));
      expect(icon.color, equals(TrueStepColors.interventionRed));
    });

    testWidgets('icon is hidden when showIcon is false', (tester) async {
      await tester.pumpCentered(
        const TrafficLightBadge(
          state: TrafficLightState.green,
          showIcon: false,
          label: 'Status',
        ),
      );

      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(find.text('Status'), findsOneWidget);
    });
  });
}
