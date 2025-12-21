import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/features/session/models/session_data.dart';
import 'package:truestep/features/session/providers/session_provider.dart';
import 'package:truestep/features/session/screens/calibration_screen.dart';

/// Test helper class to override Session with initial data
class _TestSession extends Session {
  final SessionData? _initialData;

  _TestSession(this._initialData);

  @override
  SessionData? build() => _initialData;
}

void main() {
  late Guide testGuide;

  setUp(() {
    testGuide = Guide(
      guideId: 'test-guide',
      title: 'Test Recipe',
      category: GuideCategory.culinary,
      steps: [
        GuideStep(
          stepId: 1,
          title: 'Step 1',
          instruction: 'Do step 1',
          successCriteria: 'Step 1 done',
          estimatedDuration: 60,
        ),
      ],
      totalDuration: 60,
      difficulty: GuideDifficulty.easy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  Widget createTestWidget({SessionData? sessionData}) {
    return ProviderScope(
      overrides: [
        if (sessionData != null)
          sessionProvider.overrideWith(() => _TestSession(sessionData)),
      ],
      child: const MaterialApp(home: CalibrationScreen()),
    );
  }

  group('CalibrationScreen', () {
    testWidgets('displays calibration title', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Camera Calibration'), findsOneWidget);
    });

    testWidgets('displays calibration instructions', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(
        find.textContaining('Position a reference object'),
        findsOneWidget,
      );
    });

    testWidgets('displays camera preview placeholder', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      // Look for camera preview container
      expect(find.byKey(const Key('camera_preview')), findsOneWidget);
    });

    testWidgets('displays positioning guide overlay', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byKey(const Key('positioning_overlay')), findsOneWidget);
    });

    testWidgets('displays Complete Calibration button', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Complete Calibration'), findsOneWidget);
    });

    testWidgets('displays Skip button', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Skip button shows warning dialog', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // Warning dialog should appear
      expect(find.text('Skip Calibration?'), findsOneWidget);
      expect(find.textContaining('accuracy'), findsOneWidget);
    });

    testWidgets('Skip warning dialog has Continue and Cancel buttons', (
      tester,
    ) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Skip Anyway'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays guide title in header', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('displays step indicator', (tester) async {
      final session = SessionData.start(testGuide);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      // Should show "Step 1 of 3" style indicator for calibration process
      expect(find.textContaining('Step 1'), findsOneWidget);
    });
  });
}
