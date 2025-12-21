import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/constants/colors.dart';
import 'package:truestep/shared/widgets/loading_indicator.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpCentered(const LoadingIndicator());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses green color for green state', (tester) async {
      await tester.pumpCentered(
        const LoadingIndicator(state: TrafficLightState.green),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(animation?.value, equals(TrueStepColors.sentinelGreen));
    });

    testWidgets('uses yellow color for yellow state', (tester) async {
      await tester.pumpCentered(
        const LoadingIndicator(state: TrafficLightState.yellow),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(animation?.value, equals(TrueStepColors.analysisYellow));
    });

    testWidgets('uses red color for red state', (tester) async {
      await tester.pumpCentered(
        const LoadingIndicator(state: TrafficLightState.red),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(animation?.value, equals(TrueStepColors.interventionRed));
    });

    testWidgets('respects custom size', (tester) async {
      const customSize = 64.0;

      await tester.pumpCentered(const LoadingIndicator(size: customSize));

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('shows message text when provided', (tester) async {
      await tester.pumpCentered(const LoadingIndicator(message: 'Loading...'));

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('hides message when not provided', (tester) async {
      await tester.pumpCentered(const LoadingIndicator());

      // Just verify no "Loading..." text is shown
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('default size is 48dp', (tester) async {
      await tester.pumpCentered(const LoadingIndicator());

      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(sizedBox.width, equals(48.0));
      expect(sizedBox.height, equals(48.0));
    });

    testWidgets('default state is green', (tester) async {
      await tester.pumpCentered(const LoadingIndicator());

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>?;
      expect(animation?.value, equals(TrueStepColors.sentinelGreen));
    });
  });
}
