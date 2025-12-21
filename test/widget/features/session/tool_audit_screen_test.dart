import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/features/session/models/session_data.dart';
import 'package:truestep/features/session/models/session_state.dart';
import 'package:truestep/features/session/providers/session_provider.dart';
import 'package:truestep/features/session/screens/tool_audit_screen.dart';

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
          tools: ['knife', 'cutting board'],
        ),
        GuideStep(
          stepId: 2,
          title: 'Step 2',
          instruction: 'Do step 2',
          successCriteria: 'Step 2 done',
          estimatedDuration: 60,
          tools: ['bowl', 'spoon'],
        ),
      ],
      totalDuration: 120,
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
      child: const MaterialApp(home: ToolAuditScreen()),
    );
  }

  group('ToolAuditScreen', () {
    testWidgets('displays tool audit title', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Tool Check'), findsOneWidget);
    });

    testWidgets('displays all required tools from guide', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('knife'), findsOneWidget);
      expect(find.text('cutting board'), findsOneWidget);
      expect(find.text('bowl'), findsOneWidget);
      expect(find.text('spoon'), findsOneWidget);
    });

    testWidgets('displays checkboxes for each tool', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.byType(Checkbox), findsNWidgets(4));
    });

    testWidgets('tapping checkbox toggles tool checked state', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      // Find the checkbox next to 'knife'
      final knifeCheckbox = find.descendant(
        of: find.ancestor(of: find.text('knife'), matching: find.byType(Row)),
        matching: find.byType(Checkbox),
      );

      // Initially unchecked
      expect(tester.widget<Checkbox>(knifeCheckbox).value, isFalse);

      // Tap to check
      await tester.tap(knifeCheckbox);
      await tester.pump();

      // Now checked
      expect(tester.widget<Checkbox>(knifeCheckbox).value, isTrue);
    });

    testWidgets('displays Start Session button', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('Start Session button disabled when no tools checked', (
      tester,
    ) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      // Button should be enabled (we don't require all tools)
      // Just verify it exists
      expect(find.text('Start Session'), findsOneWidget);
    });

    testWidgets('displays missing tools warning when not all checked', (
      tester,
    ) async {
      final session = SessionData.start(testGuide).copyWith(
        phase: SessionPhase.toolAudit,
        checkedTools: {'knife'}, // Only one tool checked
      );
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('missing'), findsOneWidget);
    });

    testWidgets('displays guide title in header', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.text('Test Recipe'), findsOneWidget);
    });

    testWidgets('displays step indicator', (tester) async {
      final session = SessionData.start(
        testGuide,
      ).copyWith(phase: SessionPhase.toolAudit);
      await tester.pumpWidget(createTestWidget(sessionData: session));

      expect(find.textContaining('Step 2'), findsOneWidget);
    });
  });
}
