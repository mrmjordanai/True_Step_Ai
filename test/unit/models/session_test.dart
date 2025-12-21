import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/models/session.dart';

void main() {
  group('InputMethod', () {
    test('toJson returns name', () {
      expect(InputMethod.url.toJson(), 'url');
      expect(InputMethod.text.toJson(), 'text');
      expect(InputMethod.voice.toJson(), 'voice');
    });

    test('fromJson parses valid values', () {
      expect(InputMethod.fromJson('url'), InputMethod.url);
      expect(InputMethod.fromJson('text'), InputMethod.text);
    });

    test('fromJson defaults to text for unknown', () {
      expect(InputMethod.fromJson('unknown'), InputMethod.text);
    });
  });

  group('StepLog', () {
    test('toJson and fromJson roundtrip', () {
      final log = StepLog(
        stepIndex: 0,
        verified: true,
        confidence: 0.95,
        durationSeconds: 30,
        attempts: 2,
        safetyAlert: false,
        completedAt: DateTime(2024, 1, 1, 12, 0, 0),
        clipPath: '/path/to/clip.mp4',
      );

      final json = log.toJson();
      final restored = StepLog.fromJson(json);

      expect(restored.stepIndex, 0);
      expect(restored.verified, true);
      expect(restored.confidence, 0.95);
      expect(restored.durationSeconds, 30);
      expect(restored.attempts, 2);
      expect(restored.clipPath, '/path/to/clip.mp4');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'stepIndex': 1,
        'verified': false,
        'confidence': 0.3,
        'durationSeconds': 15,
        'completedAt': DateTime.now().toIso8601String(),
      };

      final log = StepLog.fromJson(json);

      expect(log.attempts, 1);
      expect(log.safetyAlert, false);
      expect(log.clipPath, isNull);
    });
  });

  group('Recording', () {
    test('toJson and fromJson roundtrip', () {
      final recording = Recording(
        fullSessionUrl: 'https://example.com/session.mp4',
        durationSeconds: 600,
        sizeBytes: 50000000,
        retentionDays: 30,
        stepClipUrls: {0: 'https://example.com/clip0.mp4'},
      );

      final json = recording.toJson();
      final restored = Recording.fromJson(json);

      expect(restored.fullSessionUrl, 'https://example.com/session.mp4');
      expect(restored.durationSeconds, 600);
      expect(restored.sizeBytes, 50000000);
      expect(restored.stepClipUrls[0], 'https://example.com/clip0.mp4');
    });
  });

  group('Session', () {
    late Session session;
    late DateTime startedAt;
    late DateTime expiresAt;

    setUp(() {
      startedAt = DateTime(2024, 1, 1, 10, 0, 0);
      expiresAt = startedAt.add(const Duration(days: 30));
      session = Session(
        sessionId: 'session_123',
        userId: 'user_456',
        guideId: 'guide_789',
        guideTitle: 'Test Guide',
        inputMethod: InputMethod.url,
        startedAt: startedAt,
        completedAt: DateTime(2024, 1, 1, 11, 0, 0),
        expiresAt: expiresAt,
        totalSteps: 5,
        stepsCompleted: 5,
        interventionCount: 2,
        averageConfidence: 0.92,
      );
    });

    test('wasCompleted returns true when completedAt is set', () {
      expect(session.wasCompleted, true);
    });

    test('wasCompleted returns false when completedAt is null', () {
      // Create a session without completedAt set
      final incompleteSession = Session(
        sessionId: session.sessionId,
        userId: session.userId,
        guideId: session.guideId,
        guideTitle: session.guideTitle,
        inputMethod: session.inputMethod,
        startedAt: session.startedAt,
        expiresAt: session.expiresAt,
        totalSteps: session.totalSteps,
        stepsCompleted: session.stepsCompleted,
      );
      expect(incompleteSession.wasCompleted, false);
    });

    test('completionPercent calculates correctly', () {
      expect(session.completionPercent, 1.0);

      final partial = session.copyWith(stepsCompleted: 2);
      expect(partial.completionPercent, 0.4);
    });

    test('durationSeconds calculates from start to complete', () {
      expect(session.durationSeconds, 3600); // 1 hour
    });

    test('copyWith preserves values', () {
      final copied = session.copyWith(stepsCompleted: 3, interventionCount: 5);

      expect(copied.sessionId, session.sessionId);
      expect(copied.stepsCompleted, 3);
      expect(copied.interventionCount, 5);
    });
  });
}
