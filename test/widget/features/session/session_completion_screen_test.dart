import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/features/session/models/session_data.dart';
import 'package:truestep/features/session/models/session_state.dart';
import 'package:truestep/features/session/screens/session_completion_screen.dart';

void main() {
  late SessionSummary testSummary;

  setUp(() {
    final guide = Guide(
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
        GuideStep(
          stepId: 2,
          title: 'Step 2',
          instruction: 'Do step 2',
          successCriteria: 'Step 2 done',
          estimatedDuration: 60,
        ),
      ],
      totalDuration: 120,
      difficulty: GuideDifficulty.easy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testSummary = SessionSummary(
      guide: guide,
      totalDurationSeconds: 245, // 4:05
      stepsCompleted: 2,
      totalSteps: 2,
      interventionCount: 1,
      averageConfidence: 0.92,
      wasCompleted: true,
      startTime: DateTime.now().subtract(const Duration(minutes: 4)),
      endTime: DateTime.now(),
      stepResults: {
        0: VerificationResult.success(confidence: 0.95),
        1: VerificationResult.success(confidence: 0.89),
      },
    );
  });

  Widget createTestWidget(SessionSummary summary) {
    return ProviderScope(
      child: MaterialApp(home: SessionCompletionScreen(summary: summary)),
    );
  }

  group('SessionCompletionScreen', () {
    testWidgets('displays completion header', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.textContaining('Complete'), findsOneWidget);
    });

    testWidgets('displays celebration icon', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.byIcon(Icons.celebration), findsOneWidget);
    });

    testWidgets('displays guide title', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('displays completion stats', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      // Steps completed
      expect(find.text('2/2'), findsOneWidget);
      // Duration
      expect(find.textContaining('4'), findsOneWidget);
      // Confidence
      expect(find.textContaining('92'), findsOneWidget);
    });

    testWidgets('displays Done button', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('displays intervention count when > 0', (tester) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.textContaining('1'), findsOneWidget);
    });

    testWidgets('shows success message for fully completed session', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(testSummary));

      expect(find.textContaining('completed'), findsOneWidget);
    });

    testWidgets('shows partial message for incomplete session', (tester) async {
      final incomplete = SessionSummary(
        guide: testSummary.guide,
        totalDurationSeconds: 120,
        stepsCompleted: 1,
        totalSteps: 2,
        interventionCount: 0,
        averageConfidence: 0.85,
        wasCompleted: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
      await tester.pumpWidget(createTestWidget(incomplete));

      expect(find.textContaining('partial'), findsOneWidget);
    });
  });
}
