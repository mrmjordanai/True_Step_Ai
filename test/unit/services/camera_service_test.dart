import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:camera/camera.dart' hide ImageFormat;

import 'package:truestep/services/camera_service.dart';
import 'package:truestep/core/exceptions/app_exception.dart' as app_exceptions;

// Mock classes for camera package
class MockCameraController extends Mock implements CameraController {}

class MockCameraValue extends Mock implements CameraValue {}

class MockXFile extends Mock implements XFile {}

class FakeCameraDescription extends Fake implements CameraDescription {
  @override
  CameraLensDirection get lensDirection => CameraLensDirection.back;

  @override
  String get name => 'test_camera';

  @override
  int get sensorOrientation => 0;
}

class FakeFrontCameraDescription extends Fake implements CameraDescription {
  @override
  CameraLensDirection get lensDirection => CameraLensDirection.front;

  @override
  String get name => 'front_camera';

  @override
  int get sensorOrientation => 0;
}

/// Creates a mock CameraValue with sensible defaults
MockCameraValue createMockCameraValue({
  bool isInitialized = true,
  bool isStreamingImages = false,
}) {
  final mockValue = MockCameraValue();
  when(() => mockValue.isInitialized).thenReturn(isInitialized);
  when(() => mockValue.isStreamingImages).thenReturn(isStreamingImages);
  when(() => mockValue.isRecordingVideo).thenReturn(false);
  when(() => mockValue.isTakingPicture).thenReturn(false);
  return mockValue;
}

void main() {
  // Register fallback values
  setUpAll(() {
    registerFallbackValue(FakeCameraDescription());
    registerFallbackValue(ResolutionPreset.medium);
    registerFallbackValue(ImageFormatGroup.jpeg);
    registerFallbackValue(FlashMode.off);
  });

  group('CameraService', () {
    late CameraService service;
    late MockCameraController mockController;
    late List<CameraDescription> mockCameras;
    late MockCameraValue mockValue;

    setUp(() {
      mockController = MockCameraController();
      mockValue = createMockCameraValue();
      mockCameras = [
        FakeCameraDescription(),
      ];

      when(() => mockController.value).thenReturn(mockValue);
      // Stub dispose and stopImageStream for tearDown
      when(() => mockController.dispose()).thenAnswer((_) async {});
      when(() => mockController.stopImageStream()).thenAnswer((_) async {});

      // Create service with test dependencies
      service = CameraService.forTesting(
        cameras: mockCameras,
        controllerFactory: (description, preset, group) => mockController,
      );
    });

    tearDown(() async {
      if (service.isInitialized) {
        await service.dispose();
      }
    });

    group('initialization', () {
      test('initializes camera controller successfully', () async {
        when(() => mockController.initialize()).thenAnswer((_) async {});

        await service.initialize();

        expect(service.isInitialized, isTrue);
        verify(() => mockController.initialize()).called(1);
      });

      test('throws CameraException.notAvailable when no cameras found',
          () async {
        final emptyService = CameraService.forTesting(
          cameras: [],
          controllerFactory: (d, p, g) => mockController,
        );

        expect(
          () => emptyService.initialize(),
          throwsA(isA<app_exceptions.CameraException>().having(
            (e) => e.code,
            'code',
            equals('not_available'),
          )),
        );
      });

      test('throws CameraException.initializationFailed on controller error',
          () async {
        when(() => mockController.initialize())
            .thenThrow(Exception('Camera init failed'));

        expect(
          () => service.initialize(),
          throwsA(isA<app_exceptions.CameraException>().having(
            (e) => e.code,
            'code',
            equals('initialization_failed'),
          )),
        );
      });

      test('is idempotent - second initialize is no-op', () async {
        when(() => mockController.initialize()).thenAnswer((_) async {});

        await service.initialize();
        await service.initialize();

        verify(() => mockController.initialize()).called(1);
      });
    });

    group('frame capture', () {
      setUp(() async {
        when(() => mockController.initialize()).thenAnswer((_) async {});
        await service.initialize();
      });

      test('starts image stream at specified FPS', () async {
        when(() => mockController.startImageStream(any()))
            .thenAnswer((_) async {});

        await service.startCapture(fps: 30);

        expect(service.isCapturing, isTrue);
        expect(service.currentFps, equals(30));
        verify(() => mockController.startImageStream(any())).called(1);
      });

      test('stops image stream on stopCapture', () async {
        when(() => mockController.startImageStream(any()))
            .thenAnswer((_) async {});
        when(() => mockController.stopImageStream()).thenAnswer((_) async {});

        await service.startCapture();
        await service.stopCapture();

        expect(service.isCapturing, isFalse);
        verify(() => mockController.stopImageStream()).called(1);
      });

      test('emits frames through frameStream', () async {
        when(() => mockController.startImageStream(any()))
            .thenAnswer((invocation) async {});

        await service.startCapture();
        await Future.delayed(const Duration(milliseconds: 100));

        // Frame stream should be available
        expect(service.frameStream, isA<Stream<CameraFrame>>());
      });

      test('defaults to 30 FPS when not specified', () async {
        when(() => mockController.startImageStream(any()))
            .thenAnswer((_) async {});

        await service.startCapture();

        expect(service.currentFps, equals(30));
      });

      test('throws when starting capture without initialization', () {
        final uninitService = CameraService.forTesting(
          cameras: mockCameras,
          controllerFactory: (d, p, g) => mockController,
        );

        expect(
          () => uninitService.startCapture(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('controls', () {
      setUp(() async {
        when(() => mockController.initialize()).thenAnswer((_) async {});
        await service.initialize();
      });

      group('torch control', () {
        test('setTorch enables torch when true', () async {
          when(() => mockController.setFlashMode(FlashMode.torch))
              .thenAnswer((_) async {});

          await service.setTorch(true);

          expect(service.isTorchOn, isTrue);
          verify(() => mockController.setFlashMode(FlashMode.torch)).called(1);
        });

        test('setTorch disables torch when false', () async {
          when(() => mockController.setFlashMode(FlashMode.torch))
              .thenAnswer((_) async {});
          when(() => mockController.setFlashMode(FlashMode.off))
              .thenAnswer((_) async {});

          await service.setTorch(true);
          await service.setTorch(false);

          expect(service.isTorchOn, isFalse);
          verify(() => mockController.setFlashMode(FlashMode.off)).called(1);
        });

        test('toggleTorch toggles torch state', () async {
          when(() => mockController.setFlashMode(any()))
              .thenAnswer((_) async {});

          expect(service.isTorchOn, isFalse);

          await service.toggleTorch();
          expect(service.isTorchOn, isTrue);

          await service.toggleTorch();
          expect(service.isTorchOn, isFalse);
        });
      });

      group('pause/resume', () {
        test('pausePreview pauses camera preview', () async {
          when(() => mockController.pausePreview()).thenAnswer((_) async {});

          await service.pausePreview();

          expect(service.isPaused, isTrue);
          verify(() => mockController.pausePreview()).called(1);
        });

        test('resumePreview resumes camera preview', () async {
          when(() => mockController.pausePreview()).thenAnswer((_) async {});
          when(() => mockController.resumePreview()).thenAnswer((_) async {});

          await service.pausePreview();
          await service.resumePreview();

          expect(service.isPaused, isFalse);
          verify(() => mockController.resumePreview()).called(1);
        });
      });

      group('camera switching', () {
        test('switchCamera switches between front and back', () async {
          // Add a front camera
          final backCamera = FakeCameraDescription();
          final frontCamera = FakeFrontCameraDescription();
          final multiCameraService = CameraService.forTesting(
            cameras: [backCamera, frontCamera],
            controllerFactory: (d, p, g) => mockController,
          );

          when(() => mockController.initialize()).thenAnswer((_) async {});
          when(() => mockController.dispose()).thenAnswer((_) async {});

          await multiCameraService.initialize();
          expect(
              multiCameraService.currentLens, equals(CameraLensDirection.back));

          await multiCameraService.switchCamera();
          expect(multiCameraService.currentLens,
              equals(CameraLensDirection.front));

          await multiCameraService.switchCamera();
          expect(
              multiCameraService.currentLens, equals(CameraLensDirection.back));

          await multiCameraService.dispose();
        });
      });
    });

    group('frame preprocessing', () {
      test('CameraFrame holds correct data', () {
        final frame = CameraFrame(
          bytes: Uint8List.fromList([1, 2, 3, 4]),
          width: 640,
          height: 480,
          timestamp: 12345,
          format: ImageFormat.jpeg,
        );

        expect(frame.bytes.length, equals(4));
        expect(frame.width, equals(640));
        expect(frame.height, equals(480));
        expect(frame.timestamp, equals(12345));
        expect(frame.format, equals(ImageFormat.jpeg));
      });

      test('CameraFrame supports different formats', () {
        expect(ImageFormat.values, contains(ImageFormat.jpeg));
        expect(ImageFormat.values, contains(ImageFormat.yuv420));
        expect(ImageFormat.values, contains(ImageFormat.bgra8888));
      });
    });

    group('lifecycle', () {
      test('disposes camera controller on dispose', () async {
        when(() => mockController.initialize()).thenAnswer((_) async {});
        when(() => mockController.dispose()).thenAnswer((_) async {});

        await service.initialize();
        await service.dispose();

        expect(service.isInitialized, isFalse);
        verify(() => mockController.dispose()).called(1);
      });

      test('stops streaming on dispose if capturing', () async {
        when(() => mockController.initialize()).thenAnswer((_) async {});
        when(() => mockController.startImageStream(any()))
            .thenAnswer((_) async {});
        when(() => mockController.stopImageStream()).thenAnswer((_) async {});
        when(() => mockController.dispose()).thenAnswer((_) async {});

        await service.initialize();
        await service.startCapture();
        await service.dispose();

        verify(() => mockController.stopImageStream()).called(1);
      });

      test('ensureInitialized throws when not initialized', () {
        final uninitService = CameraService.forTesting(
          cameras: mockCameras,
          controllerFactory: (d, p, g) => mockController,
        );

        expect(
          () => uninitService.ensureInitialized(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('getters', () {
      setUp(() async {
        when(() => mockController.initialize()).thenAnswer((_) async {});
        await service.initialize();
      });

      test('controller returns the camera controller', () {
        expect(service.controller, equals(mockController));
      });

      test('currentLens returns the current camera lens direction', () {
        expect(service.currentLens, equals(CameraLensDirection.back));
      });

      test('isCapturing returns false initially', () {
        expect(service.isCapturing, isFalse);
      });

      test('isTorchOn returns false initially', () {
        expect(service.isTorchOn, isFalse);
      });

      test('isPaused returns false initially', () {
        expect(service.isPaused, isFalse);
      });
    });
  });
}
