import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:camera/camera.dart' hide ImageFormat;

import 'package:truestep/features/session/providers/camera_provider.dart';
import 'package:truestep/services/camera_service.dart';
import 'package:truestep/core/exceptions/app_exception.dart' as app_exceptions;

import '../../helpers/mock_services.dart';

void main() {
  setUpAll(() {
    registerFallbackValues();
  });

  group('CameraState', () {
    test('initial state is uninitialized', () {
      const state = CameraState.uninitialized();
      expect(state.status, equals(CameraStatus.uninitialized));
      expect(state.error, isNull);
      expect(state.isCapturing, isFalse);
      expect(state.isTorchOn, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.currentLens, isNull);
    });

    test('initializing state has correct status', () {
      const state = CameraState.initializing();
      expect(state.status, equals(CameraStatus.initializing));
      expect(state.error, isNull);
    });

    test('ready state contains lens direction', () {
      const state = CameraState.ready(
        currentLens: CameraLensDirection.back,
      );

      expect(state.status, equals(CameraStatus.ready));
      expect(state.currentLens, equals(CameraLensDirection.back));
      expect(state.error, isNull);
    });

    test('capturing state has capturing flag true', () {
      const state = CameraState.capturing(
        currentLens: CameraLensDirection.back,
        isTorchOn: false,
      );

      expect(state.status, equals(CameraStatus.capturing));
      expect(state.isCapturing, isTrue);
      expect(state.currentLens, equals(CameraLensDirection.back));
    });

    test('error state contains exception', () {
      final exception = app_exceptions.CameraException.notAvailable();
      final state = CameraState.error(exception);

      expect(state.status, equals(CameraStatus.error));
      expect(state.error, equals(exception));
    });

    test('isReady returns true for ready and capturing states', () {
      expect(const CameraState.uninitialized().isReady, isFalse);
      expect(const CameraState.initializing().isReady, isFalse);
      expect(
        const CameraState.ready(currentLens: CameraLensDirection.back).isReady,
        isTrue,
      );
      expect(
        const CameraState.capturing(
          currentLens: CameraLensDirection.back,
          isTorchOn: false,
        ).isReady,
        isTrue,
      );
      expect(
        CameraState.error(app_exceptions.CameraException.notAvailable()).isReady,
        isFalse,
      );
    });

    test('hasError returns true only for error status', () {
      expect(const CameraState.uninitialized().hasError, isFalse);
      expect(const CameraState.ready(currentLens: CameraLensDirection.back).hasError, isFalse);
      expect(
        CameraState.error(app_exceptions.CameraException.notAvailable()).hasError,
        isTrue,
      );
    });

    test('copyWith creates a new state with updated values', () {
      const state = CameraState.ready(
        currentLens: CameraLensDirection.back,
      );

      final updated = state.copyWith(isTorchOn: true);

      expect(updated.status, equals(CameraStatus.ready));
      expect(updated.isTorchOn, isTrue);
      expect(updated.currentLens, equals(CameraLensDirection.back));
    });
  });

  group('CameraNotifier', () {
    late MockCameraService mockService;
    late ProviderContainer container;
    late CameraNotifier notifier;

    setUp(() {
      mockService = createMockCameraService(isInitialized: false);
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      container = ProviderContainer(
        overrides: [
          cameraServiceProvider.overrideWithValue(mockService),
        ],
      );
      notifier = container.read(cameraNotifierProvider.notifier);
      return container;
    }

    test('initial state is uninitialized', () {
      createContainer();
      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.uninitialized));
    });

    test('initialize sets initializing then ready state', () async {
      // Add delay to mock so we can observe initializing state
      when(() => mockService.initialize()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);

      createContainer();

      // Start initialization (don't await yet)
      final future = notifier.initialize();

      // Give time for state to update to initializing
      await Future.delayed(const Duration(milliseconds: 10));

      // Check initializing state
      expect(
        container.read(cameraNotifierProvider).status,
        equals(CameraStatus.initializing),
      );

      // Wait for completion
      await future;

      // Check ready state
      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.ready));
      expect(state.currentLens, equals(CameraLensDirection.back));
    });

    test('initialize sets error state on exception', () async {
      final exception = app_exceptions.CameraException.notAvailable();
      when(() => mockService.initialize()).thenThrow(exception);

      createContainer();

      await notifier.initialize();

      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.error));
      expect(state.error, equals(exception));
    });

    test('startCapture transitions to capturing state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.isTorchOn).thenReturn(false);
      when(() => mockService.startCapture(fps: any(named: 'fps')))
          .thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.startCapture();

      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.capturing));
      expect(state.isCapturing, isTrue);
      verify(() => mockService.startCapture(fps: 30)).called(1);
    });

    test('startCapture with custom fps passes correct value', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.isTorchOn).thenReturn(false);
      when(() => mockService.startCapture(fps: any(named: 'fps')))
          .thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.startCapture(fps: 15);

      verify(() => mockService.startCapture(fps: 15)).called(1);
    });

    test('stopCapture transitions back to ready state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.isTorchOn).thenReturn(false);
      when(() => mockService.startCapture(fps: any(named: 'fps')))
          .thenAnswer((_) async {});
      when(() => mockService.stopCapture()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.startCapture();
      await notifier.stopCapture();

      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.ready));
      expect(state.isCapturing, isFalse);
      verify(() => mockService.stopCapture()).called(1);
    });

    test('toggleTorch toggles torch state', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.isTorchOn).thenReturn(false);
      when(() => mockService.toggleTorch()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.toggleTorch();

      verify(() => mockService.toggleTorch()).called(1);
    });

    test('setTorch sets torch to specific value', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.setTorch(any())).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.setTorch(true);

      verify(() => mockService.setTorch(true)).called(1);
    });

    test('switchCamera switches and updates lens direction', () async {
      var callCount = 0;
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenAnswer((_) {
        callCount++;
        return callCount <= 1
            ? CameraLensDirection.back
            : CameraLensDirection.front;
      });
      when(() => mockService.switchCamera()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();

      expect(
        container.read(cameraNotifierProvider).currentLens,
        equals(CameraLensDirection.back),
      );

      await notifier.switchCamera();

      final state = container.read(cameraNotifierProvider);
      expect(state.currentLens, equals(CameraLensDirection.front));
      verify(() => mockService.switchCamera()).called(1);
    });

    test('pausePreview sets paused flag', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.pausePreview()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.pausePreview();

      final state = container.read(cameraNotifierProvider);
      expect(state.isPaused, isTrue);
      verify(() => mockService.pausePreview()).called(1);
    });

    test('resumePreview clears paused flag', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.pausePreview()).thenAnswer((_) async {});
      when(() => mockService.resumePreview()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.pausePreview();
      await notifier.resumePreview();

      final state = container.read(cameraNotifierProvider);
      expect(state.isPaused, isFalse);
      verify(() => mockService.resumePreview()).called(1);
    });

    test('operations throw when not initialized', () async {
      when(() => mockService.isInitialized).thenReturn(false);
      when(() => mockService.startCapture(fps: any(named: 'fps')))
          .thenThrow(StateError('Not initialized'));

      createContainer();

      expect(
        () => notifier.startCapture(),
        throwsA(isA<StateError>()),
      );
    });

    test('frameStream provides frames from service', () async {
      final frameController = StreamController<CameraFrame>.broadcast();

      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.frameStream).thenAnswer((_) => frameController.stream);

      createContainer();

      await notifier.initialize();

      // Access the stream directly from the service
      final frames = <CameraFrame>[];
      final sub = mockService.frameStream.listen(frames.add);

      final testFrame = CameraFrame(
        bytes: Uint8List.fromList([1, 2, 3]),
        width: 640,
        height: 480,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        format: ImageFormat.jpeg,
      );

      frameController.add(testFrame);
      await Future.delayed(const Duration(milliseconds: 10));

      expect(frames.length, equals(1));
      expect(frames.first.width, equals(640));

      await sub.cancel();
      await frameController.close();
    });

    test('disposeCamera cleans up resources', () async {
      when(() => mockService.initialize()).thenAnswer((_) async {});
      when(() => mockService.isInitialized).thenReturn(true);
      when(() => mockService.currentLens).thenReturn(CameraLensDirection.back);
      when(() => mockService.dispose()).thenAnswer((_) async {});

      createContainer();

      await notifier.initialize();
      await notifier.disposeCamera();

      verify(() => mockService.dispose()).called(1);
    });

    test('clearError returns to uninitialized state from error', () async {
      final exception = app_exceptions.CameraException.notAvailable();
      when(() => mockService.initialize()).thenThrow(exception);

      createContainer();

      await notifier.initialize();
      expect(
        container.read(cameraNotifierProvider).status,
        equals(CameraStatus.error),
      );

      notifier.clearError();

      expect(
        container.read(cameraNotifierProvider).status,
        equals(CameraStatus.uninitialized),
      );
    });
  });
}
