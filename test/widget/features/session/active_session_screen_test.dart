import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/features/session/models/session_data.dart';
import 'package:truestep/features/session/models/session_state.dart';
import 'package:truestep/features/session/providers/session_provider.dart';
import 'package:truestep/features/session/screens/active_session_screen.dart';

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
          title: 'Chop vegetables',
          instruction: 'Chop the onions finely',
          successCriteria: 'Onions finely chopped',
          estimatedDuration: 60,
        ),
        GuideStep(
          stepId: 2,
          title: 'Heat pan',
          instruction: 'Heat the pan with oil',
          successCriteria: 'Pan heated',
          estimatedDuration: 30,
        ),
      ],
      totalDuration: 90,
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
      child: const MaterialApp(home: ActiveSessionScreen()),
    );
  }

  group('ActiveSessionScreen', () {
    testWidgets('displays traffic light header', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byKey(const Key('traffic_light_header')), findsOneWidget);
    });

    testWidgets('displays GREEN state when watching', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('Watching'), findsOneWidget);
    });

    testWidgets('displays YELLOW state when verifying', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.verifying,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('Verifying'), findsOneWidget);
    });

    testWidgets('displays RED state when intervention', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.intervention,
        interventionMessage: 'Check required',
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('Attention'), findsOneWidget);
    });

    testWidgets('displays current step title', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Chop vegetables'), findsOneWidget);
    });

    testWidgets('displays current step instruction', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Chop the onions finely'), findsOneWidget);
    });

    testWidgets('displays step progress indicator', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
        currentStepIndex: 0,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('1 of 2'), findsOneWidget);
    });

    testWidgets('displays verify button', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byKey(const Key('verify_button')), findsOneWidget);
    });

    testWidgets('displays camera preview area', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byKey(const Key('camera_preview_area')), findsOneWidget);
    });

    testWidgets('displays elapsed time', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
        elapsedSeconds: 125, // 2:05
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('2:05'), findsOneWidget);
    });

    testWidgets('displays pause button', (tester) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.active,
        sentinelState: SentinelState.watching,
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
}
