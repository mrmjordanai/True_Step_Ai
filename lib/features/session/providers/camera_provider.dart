import 'package:camera/camera.dart' hide ImageFormat;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/app_exception.dart' as app_exceptions;
import '../../../services/camera_service.dart';

part 'camera_provider.g.dart';

/// Status of the camera
enum CameraStatus {
  /// Camera not initialized
  uninitialized,

  /// Camera is initializing
  initializing,

  /// Camera is ready but not capturing
  ready,

  /// Camera is actively capturing frames
  capturing,

  /// An error occurred
  error,
}

/// State for camera management
class CameraState {
  /// Current status
  final CameraStatus status;

  /// Whether actively capturing frames
  final bool isCapturing;

  /// Whether torch is enabled
  final bool isTorchOn;

  /// Whether preview is paused
  final bool isPaused;

  /// Current camera lens direction
  final CameraLensDirection? currentLens;

  /// Error that occurred (if any)
  final app_exceptions.CameraException? error;

  const CameraState._({
    required this.status,
    this.isCapturing = false,
    this.isTorchOn = false,
    this.isPaused = false,
    this.currentLens,
    this.error,
  });

  /// Create uninitialized state
  const CameraState.uninitialized()
    : status = CameraStatus.uninitialized,
      isCapturing = false,
      isTorchOn = false,
      isPaused = false,
      currentLens = null,
      error = null;

  /// Create initializing state
  const CameraState.initializing()
    : status = CameraStatus.initializing,
      isCapturing = false,
      isTorchOn = false,
      isPaused = false,
      currentLens = null,
      error = null;

  /// Create ready state
  const CameraState.ready({
    required CameraLensDirection currentLens,
    bool isTorchOn = false,
    bool isPaused = false,
  }) : status = CameraStatus.ready,
       isCapturing = false,
       isTorchOn = isTorchOn,
       isPaused = isPaused,
       currentLens = currentLens,
       error = null;

  /// Create capturing state
  const CameraState.capturing({
    required CameraLensDirection currentLens,
    required bool isTorchOn,
    bool isPaused = false,
  }) : status = CameraStatus.capturing,
       isCapturing = true,
       isTorchOn = isTorchOn,
       isPaused = isPaused,
       currentLens = currentLens,
       error = null;

  /// Create error state
  CameraState.error(app_exceptions.CameraException this.error)
    : status = CameraStatus.error,
      isCapturing = false,
      isTorchOn = false,
      isPaused = false,
      currentLens = null;

  /// Whether camera is ready (ready or capturing)
  bool get isReady =>
      status == CameraStatus.ready || status == CameraStatus.capturing;

  /// Whether an error occurred
  bool get hasError => status == CameraStatus.error;

  /// Create a copy with updated values
  CameraState copyWith({
    CameraStatus? status,
    bool? isCapturing,
    bool? isTorchOn,
    bool? isPaused,
    CameraLensDirection? currentLens,
    app_exceptions.CameraException? error,
  }) {
    return CameraState._(
      status: status ?? this.status,
      isCapturing: isCapturing ?? this.isCapturing,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      isPaused: isPaused ?? this.isPaused,
      currentLens: currentLens ?? this.currentLens,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraState &&
        other.status == status &&
        other.isCapturing == isCapturing &&
        other.isTorchOn == isTorchOn &&
        other.isPaused == isPaused &&
        other.currentLens == currentLens &&
        other.error == error;
  }

  @override
  int get hashCode =>
      Object.hash(status, isCapturing, isTorchOn, isPaused, currentLens, error);
}

/// Provider for camera service (can be overridden in tests)
@riverpod
CameraService cameraService(CameraServiceRef ref) {
  return CameraService();
}

/// Notifier for managing camera state
@Riverpod(keepAlive: true)
class CameraNotifier extends _$CameraNotifier {
  CameraService get _service => ref.read(cameraServiceProvider);

  @override
  CameraState build() => const CameraState.uninitialized();

  /// Initialize the camera
  Future<void> initialize() async {
    if (state.status == CameraStatus.initializing ||
        state.status == CameraStatus.ready ||
        state.status == CameraStatus.capturing) {
      return;
    }

    state = const CameraState.initializing();

    try {
      await _service.initialize();
      state = CameraState.ready(currentLens: _service.currentLens);
    } on app_exceptions.CameraException catch (e) {
      state = CameraState.error(e);
    } catch (e) {
      state = CameraState.error(
        app_exceptions.CameraException(
          e.toString(),
          code: 'unknown_error',
          originalError: e,
        ),
      );
    }
  }

  /// Start capturing frames
  Future<void> startCapture({int fps = 30}) async {
    _ensureReady();

    await _service.startCapture(fps: fps);
    state = CameraState.capturing(
      currentLens: _service.currentLens,
      isTorchOn: _service.isTorchOn,
    );
  }

  /// Stop capturing frames
  Future<void> stopCapture() async {
    if (!state.isCapturing) return;

    await _service.stopCapture();
    state = CameraState.ready(
      currentLens: _service.currentLens,
      isTorchOn: state.isTorchOn,
      isPaused: state.isPaused,
    );
  }

  /// Toggle the torch
  Future<void> toggleTorch() async {
    _ensureReady();

    await _service.toggleTorch();
    state = state.copyWith(isTorchOn: _service.isTorchOn);
  }

  /// Set torch to specific value
  Future<void> setTorch(bool on) async {
    _ensureReady();

    await _service.setTorch(on);
    state = state.copyWith(isTorchOn: on);
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    _ensureReady();

    await _service.switchCamera();
    state = state.copyWith(currentLens: _service.currentLens);
  }

  /// Pause the camera preview
  Future<void> pausePreview() async {
    _ensureReady();

    await _service.pausePreview();
    state = state.copyWith(isPaused: true);
  }

  /// Resume the camera preview
  Future<void> resumePreview() async {
    _ensureReady();

    await _service.resumePreview();
    state = state.copyWith(isPaused: false);
  }

  /// Dispose the camera resources
  Future<void> disposeCamera() async {
    await _service.dispose();
    state = const CameraState.uninitialized();
  }

  /// Clear error and return to uninitialized state
  void clearError() {
    if (state.hasError) {
      state = const CameraState.uninitialized();
    }
  }

  /// Ensure camera is ready before operations
  void _ensureReady() {
    if (!state.isReady) {
      throw StateError('Camera is not ready. Current status: ${state.status}');
    }
  }
}

/// Provider for camera frame stream
@riverpod
Stream<CameraFrame> cameraFrameStream(CameraFrameStreamRef ref) {
  final service = ref.watch(cameraServiceProvider);
  return service.frameStream;
}
