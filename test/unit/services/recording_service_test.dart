import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/services/recording_service.dart';

void main() {
  group('LocalRecordingData', () {
    test('can be created with required fields', () {
      final data = LocalRecordingData(
        fullSessionPath: '/path/to/session.mp4',
        durationSeconds: 600,
      );

      expect(data.fullSessionPath, '/path/to/session.mp4');
      expect(data.durationSeconds, 600);
      expect(data.stepClipPaths, isEmpty);
    });

    test('can be created with step clips', () {
      final data = LocalRecordingData(
        fullSessionPath: '/path/to/session.mp4',
        durationSeconds: 600,
        stepClipPaths: {0: '/path/to/clip0.jpg', 1: '/path/to/clip1.jpg'},
      );

      expect(data.stepClipPaths.length, 2);
      expect(data.stepClipPaths[0], '/path/to/clip0.jpg');
    });
  });

  group('RecordingService', () {
    late RecordingService service;

    setUp(() {
      service = RecordingService();
    });

    test('can be instantiated', () {
      expect(service, isNotNull);
      expect(service.isRecording, false);
      expect(service.isPaused, false);
      expect(service.currentSessionId, isNull);
    });

    test('ensureInitialized throws when not initialized', () {
      expect(() => service.ensureInitialized(), throwsA(isA<StateError>()));
    });
  });
}
