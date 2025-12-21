import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/features/session/models/session_data.dart';
import 'package:truestep/features/session/models/session_state.dart';
import 'package:truestep/features/session/providers/session_provider.dart';

void main() {
  group('SentinelState', () {
    test('has all traffic light states', () {
      expect(SentinelState.values, hasLength(3));
      expect(SentinelState.watching, isNotNull);
      expect(SentinelState.verifying, isNotNull);
      expect(SentinelState.intervention, isNotNull);
    });
  });

  group('SessionPhase', () {
    test('has all lifecycle phases', () {
      expect(SessionPhase.values, hasLength(6));
      expect(SessionPhase.calibrating, isNotNull);
      expect(SessionPhase.toolAudit, isNotNull);
      expect(SessionPhase.active, isNotNull);
      expect(SessionPhase.paused, isNotNull);
      expect(SessionPhase.completed, isNotNull);
      expect(SessionPhase.cancelled, isNotNull);
    });
  });

  group('VerificationResult', () {
    test('success factory creates verified result', () {
      final result = VerificationResult.success(confidence: 0.95);

      expect(result.verified, isTrue);
      expect(result.confidence, 0.95);
      expect(result.issue, isNull);
      expect(result.safetyAlert, isFalse);
    });

    test('failure factory creates non-verified result', () {
      final result = VerificationResult.failure(
        issue: 'Step incomplete',
        confidence: 0.3,
        safetyAlert: true,
        suggestion: 'Try again',
      );

      expect(result.verified, isFalse);
      expect(result.confidence, 0.3);
      expect(result.issue, 'Step incomplete');
      expect(result.safetyAlert, isTrue);
      expect(result.suggestion, 'Try again');
    });

    test('toJson and fromJson are reversible', () {
      final original = VerificationResult.failure(
        issue: 'Test issue',
        confidence: 0.5,
        safetyAlert: true,
        suggestion: 'Fix it',
      );

      final json = original.toJson();
      final restored = VerificationResult.fromJson(json);

      expect(restored.verified, original.verified);
      expect(restored.confidence, original.confidence);
      expect(restored.issue, original.issue);
      expect(restored.safetyAlert, original.safetyAlert);
      expect(restored.suggestion, original.suggestion);
    });
  });

  group('SessionData', () {
    late Guide testGuide;

    setUp(() {
      testGuide = Guide(
        guideId: 'test-guide',
        title: 'Test Guide',
        category: GuideCategory.culinary,
        steps: [
          GuideStep(
            stepId: 1,
            title: 'Step 1',
            instruction: 'Do step 1',
            successCriteria: 'Step 1 is done',
            estimatedDuration: 60,
          ),
          GuideStep(
            stepId: 2,
            title: 'Step 2',
            instruction: 'Do step 2',
            successCriteria: 'Step 2 is done',
            estimatedDuration: 120,
          ),
          GuideStep(
            stepId: 3,
            title: 'Step 3',
            instruction: 'Do step 3',
            successCriteria: 'Step 3 is done',
            estimatedDuration: 60,
          ),
        ],
        totalDuration: 240,
        difficulty: GuideDifficulty.easy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('start creates session with default values', () {
      final session = SessionData.start(testGuide);

      expect(session.guide, testGuide);
      expect(session.phase, SessionPhase.calibrating);
      expect(session.sentinelState, SentinelState.watching);
      expect(session.currentStepIndex, 0);
      expect(session.elapsedSeconds, 0);
      expect(session.interventionCount, 0);
      expect(session.isRecording, isFalse);
    });

    test('currentStep returns correct step', () {
      final session = SessionData.start(testGuide);

      expect(session.currentStep.stepId, 1);
      expect(session.currentStep.title, 'Step 1');
    });

    test('isFirstStep and isLastStep are correct', () {
      var session = SessionData.start(testGuide);
      expect(session.isFirstStep, isTrue);
      expect(session.isLastStep, isFalse);

      session = session.copyWith(currentStepIndex: 1);
      expect(session.isFirstStep, isFalse);
      expect(session.isLastStep, isFalse);

      session = session.copyWith(currentStepIndex: 2);
      expect(session.isFirstStep, isFalse);
      expect(session.isLastStep, isTrue);
    });

    test('progressPercent calculates correctly', () {
      var session = SessionData.start(testGuide);
      expect(session.progressPercent, closeTo(1 / 3, 0.01));

      session = session.copyWith(currentStepIndex: 1);
      expect(session.progressPercent, closeTo(2 / 3, 0.01));

      session = session.copyWith(currentStepIndex: 2);
      expect(session.progressPercent, closeTo(1.0, 0.01));
    });

    test('copyWith creates correct copy', () {
      final session = SessionData.start(testGuide);
      final updated = session.copyWith(
        phase: SessionPhase.active,
        currentStepIndex: 1,
        elapsedSeconds: 30,
      );

      expect(updated.phase, SessionPhase.active);
      expect(updated.currentStepIndex, 1);
      expect(updated.elapsedSeconds, 30);
      expect(updated.guide, testGuide); // Unchanged
    });

    test('clearIntervention clears message and resets sentinel', () {
      final session = SessionData.start(testGuide).copyWith(
        sentinelState: SentinelState.intervention,
        interventionMessage: 'Error!',
      );

      final cleared = session.clearIntervention();

      expect(cleared.sentinelState, SentinelState.watching);
      expect(cleared.interventionMessage, isNull);
    });

    test('isActive is true for active phases', () {
      var session = SessionData.start(testGuide);
      expect(session.isActive, isTrue); // calibrating

      session = session.copyWith(phase: SessionPhase.toolAudit);
      expect(session.isActive, isTrue);

      session = session.copyWith(phase: SessionPhase.active);
      expect(session.isActive, isTrue);

      session = session.copyWith(phase: SessionPhase.paused);
      expect(session.isActive, isFalse);

      session = session.copyWith(phase: SessionPhase.completed);
      expect(session.isActive, isFalse);
    });
  });

  group('SessionSummary', () {
    test('fromSession creates correct summary', () {
      final guide = Guide(
        guideId: 'test',
        title: 'Test',
        category: GuideCategory.diy,
        steps: [
          GuideStep(
            stepId: 1,
            title: 'Step 1',
            instruction: 'Do it',
            successCriteria: 'Done',
            estimatedDuration: 60,
          ),
        ],
        totalDuration: 60,
        difficulty: GuideDifficulty.easy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final session = SessionData(
        guide: guide,
        phase: SessionPhase.completed,
        elapsedSeconds: 120,
        interventionCount: 2,
        stepResults: {0: VerificationResult.success(confidence: 0.9)},
        startTime: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      final summary = SessionSummary.fromSession(session);

      expect(summary.wasCompleted, isTrue);
      expect(summary.totalDurationSeconds, 120);
      expect(summary.stepsCompleted, 1);
      expect(summary.totalSteps, 1);
      expect(summary.interventionCount, 2);
      expect(summary.averageConfidence, closeTo(0.9, 0.01));
    });

    test('formattedDuration formats correctly', () {
      final summary = SessionSummary(
        guide: Guide(
          guideId: 'test',
          title: 'Test',
          category: GuideCategory.diy,
          steps: [],
          totalDuration: 0,
          difficulty: GuideDifficulty.easy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        totalDurationSeconds: 125,
        stepsCompleted: 0,
        totalSteps: 0,
        interventionCount: 0,
        averageConfidence: 0,
        wasCompleted: true,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      expect(summary.formattedDuration, '2m 5s');
    });
  });

  group('SessionNotifier', () {
    late SessionNotifier notifier;
    late Guide testGuide;

    setUp(() {
      notifier = SessionNotifier();
      testGuide = Guide(
        guideId: 'test-guide',
        title: 'Test Guide',
        category: GuideCategory.culinary,
        steps: [
          GuideStep(
            stepId: 1,
            title: 'Step 1',
            instruction: 'Do step 1',
            successCriteria: 'Step 1 is done',
            estimatedDuration: 60,
          ),
          GuideStep(
            stepId: 2,
            title: 'Step 2',
            instruction: 'Do step 2',
            successCriteria: 'Step 2 is done',
            estimatedDuration: 60,
          ),
        ],
        totalDuration: 120,
        difficulty: GuideDifficulty.easy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state is null', () {
      expect(notifier.state, isNull);
    });

    test('startSession creates session in calibrating phase', () async {
      await notifier.startSession(testGuide);

      expect(notifier.state, isNotNull);
      expect(notifier.state!.phase, SessionPhase.calibrating);
      expect(notifier.state!.guide, testGuide);
    });

    test('completeCalibration transitions to toolAudit', () async {
      await notifier.startSession(testGuide);
      notifier.completeCalibration();

      expect(notifier.state!.phase, SessionPhase.toolAudit);
      expect(notifier.state!.calibrationSkipped, isFalse);
    });

    test('skipCalibration transitions to toolAudit with flag', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();

      expect(notifier.state!.phase, SessionPhase.toolAudit);
      expect(notifier.state!.calibrationSkipped, isTrue);
    });

    test('confirmToolsReady transitions to active', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      expect(notifier.state!.phase, SessionPhase.active);
      expect(notifier.state!.sentinelState, SentinelState.watching);
    });

    test('toggleTool adds and removes tools', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();

      expect(notifier.state!.checkedTools, isEmpty);

      notifier.toggleTool('knife');
      expect(notifier.state!.checkedTools, contains('knife'));

      notifier.toggleTool('bowl');
      expect(notifier.state!.checkedTools, containsAll(['knife', 'bowl']));

      notifier.toggleTool('knife');
      expect(notifier.state!.checkedTools, isNot(contains('knife')));
      expect(notifier.state!.checkedTools, contains('bowl'));
    });

    test('nextStep advances current step', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      expect(notifier.state!.currentStepIndex, 0);

      notifier.nextStep();
      expect(notifier.state!.currentStepIndex, 1);
    });

    test('nextStep does nothing on last step', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();
      notifier.nextStep(); // Now on step 2 (last)

      expect(notifier.state!.currentStepIndex, 1);

      notifier.nextStep(); // Should not advance
      expect(notifier.state!.currentStepIndex, 1);
    });

    test('previousStep goes back', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();
      notifier.nextStep();

      expect(notifier.state!.currentStepIndex, 1);

      notifier.previousStep();
      expect(notifier.state!.currentStepIndex, 0);
    });

    test('previousStep does nothing on first step', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      expect(notifier.state!.currentStepIndex, 0);

      notifier.previousStep();
      expect(notifier.state!.currentStepIndex, 0);
    });

    test('pauseSession and resumeSession work', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      notifier.pauseSession();
      expect(notifier.state!.phase, SessionPhase.paused);

      notifier.resumeSession();
      expect(notifier.state!.phase, SessionPhase.active);
    });

    test('cancelSession clears state', () async {
      await notifier.startSession(testGuide);
      await notifier.cancelSession();

      expect(notifier.state, isNull);
    });

    test('skipStep advances without verification', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      expect(notifier.state!.currentStepIndex, 0);
      expect(notifier.state!.stepResults, isEmpty);

      notifier.skipStep();

      expect(notifier.state!.currentStepIndex, 1);
      expect(notifier.state!.stepResults, isEmpty); // No verification recorded
    });

    test('skipStep on last step completes session', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();
      notifier.nextStep(); // Go to last step

      notifier.skipStep();

      expect(notifier.state!.phase, SessionPhase.completed);
    });

    test('triggerVerification transitions through states', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      // Should start in watching
      expect(notifier.state!.sentinelState, SentinelState.watching);

      // Trigger verification - this will complete async
      final future = notifier.triggerVerification();

      // Should immediately transition to verifying
      expect(notifier.state!.sentinelState, SentinelState.verifying);

      // Wait for mock verification to complete
      await future;

      // Should be back to watching or in intervention
      expect(
        notifier.state!.sentinelState,
        anyOf(SentinelState.watching, SentinelState.intervention),
      );
    });

    test('resolveIntervention clears intervention state', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      // Force into intervention state
      notifier.state = notifier.state!.copyWith(
        sentinelState: SentinelState.intervention,
        interventionMessage: 'Test error',
      );

      notifier.resolveIntervention(reVerify: false);

      expect(notifier.state!.sentinelState, SentinelState.watching);
      expect(notifier.state!.interventionMessage, isNull);
    });

    test('completeSession returns summary', () async {
      await notifier.startSession(testGuide);
      notifier.skipCalibration();
      notifier.confirmToolsReady();

      final summary = notifier.completeSession();

      expect(summary, isNotNull);
      expect(summary!.guide, testGuide);
      expect(summary.wasCompleted, isTrue);
    });
  });
}
