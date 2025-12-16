import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'base_service.dart';
import '../core/exceptions/app_exception.dart' as app_exceptions;

/// Alias for our app's CameraException to avoid conflict with camera package
typedef AppCameraException = app_exceptions.CameraException;

/// Supported image formats for camera frames
enum ImageFormat {
  /// JPEG compressed format
  jpeg,

  /// YUV420 format (Android default)
  yuv420,

  /// BGRA8888 format (iOS default)
  bgra8888,
}

/// A processed camera frame for AI verification
class CameraFrame {
  /// Raw image bytes
  final Uint8List bytes;

  /// Frame width in pixels
  final int width;

  /// Frame height in pixels
  final int height;

  /// Timestamp in milliseconds since epoch
  final int timestamp;

  /// Image format
  final ImageFormat format;

  const CameraFrame({
    required this.bytes,
    required this.width,
    required this.height,
    required this.timestamp,
    required this.format,
  });
}

/// Factory function type for creating camera controllers (for testing)
typedef CameraControllerFactory = CameraController Function(
  CameraDescription description,
  ResolutionPreset preset,
  ImageFormatGroup formatGroup,
);

/// Service for camera hardware control
///
/// Provides camera initialization, frame capture, and controls
/// for the TrueStep visual verification system.
class CameraService extends BaseService {
  /// Available cameras on the device
  List<CameraDescription> _cameras;

  /// Factory for creating camera controllers (overridable for testing)
  final CameraControllerFactory? _controllerFactory;

  /// Whether cameras were injected (for testing)
  final bool _camerasInjected;

  /// Current camera controller
  CameraController? _controller;

  /// Index of the current camera in the cameras list
  int _currentCameraIndex = 0;

  /// Stream controller for processed frames
  final StreamController<CameraFrame> _frameStreamController =
      StreamController<CameraFrame>.broadcast();

  /// Whether the camera is currently capturing frames
  bool _isCapturing = false;

  /// Current target FPS
  int _currentFps = 30;

  /// Whether the torch is on
  bool _isTorchOn = false;

  /// Whether the preview is paused
  bool _isPaused = false;

  /// Timer for frame rate limiting
  Timer? _frameTimer;

  /// Last frame timestamp for rate limiting
  int _lastFrameTime = 0;

  /// Creates a new CameraService
  CameraService()
      : _cameras = [],
        _controllerFactory = null,
        _camerasInjected = false;

  /// Creates a CameraService for testing with injected dependencies
  @visibleForTesting
  CameraService.forTesting({
    required List<CameraDescription> cameras,
    CameraControllerFactory? controllerFactory,
  })  : _cameras = cameras,
        _controllerFactory = controllerFactory,
        _camerasInjected = true;

  /// Stream of processed camera frames
  Stream<CameraFrame> get frameStream => _frameStreamController.stream;

  /// The current camera controller
  CameraController? get controller => _controller;

  /// Whether the camera is currently capturing frames
  bool get isCapturing => _isCapturing;

  /// Current capture FPS
  int get currentFps => _currentFps;

  /// Whether the torch is enabled
  bool get isTorchOn => _isTorchOn;

  /// Whether the preview is paused
  bool get isPaused => _isPaused;

  /// Current camera lens direction
  CameraLensDirection get currentLens {
    if (_cameras.isEmpty) return CameraLensDirection.back;
    return _cameras[_currentCameraIndex].lensDirection;
  }

  @override
  Future<void> onInitialize() async {
    // Get available cameras if not injected via forTesting
    if (!_camerasInjected) {
      _cameras = await availableCameras();
    }

    if (_cameras.isEmpty) {
      throw AppCameraException.notAvailable();
    }

    // Find back camera first, fall back to first available
    _currentCameraIndex = _cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (_currentCameraIndex < 0) {
      _currentCameraIndex = 0;
    }

    await _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final camera = _cameras[_currentCameraIndex];

      _controller = _controllerFactory?.call(
            camera,
            ResolutionPreset.medium,
            ImageFormatGroup.jpeg,
          ) ??
          CameraController(
            camera,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

      await _controller!.initialize();
    } catch (e) {
      throw AppCameraException.initializationFailed(e.toString());
    }
  }

  @override
  Future<void> onDispose() async {
    if (_isCapturing) {
      await stopCapture();
    }
    _frameTimer?.cancel();
    await _controller?.dispose();
    _controller = null;
    await _frameStreamController.close();
  }

  /// Start capturing frames at the specified FPS
  ///
  /// Defaults to 30 FPS if not specified.
  Future<void> startCapture({int fps = 30}) async {
    ensureInitialized();

    if (_isCapturing) return;

    _currentFps = fps;
    _isCapturing = true;
    _lastFrameTime = 0;

    final minFrameInterval = Duration(milliseconds: (1000 / fps).round());

    await _controller!.startImageStream((CameraImage image) {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Rate limit frames based on FPS
      if (now - _lastFrameTime < minFrameInterval.inMilliseconds) {
        return;
      }
      _lastFrameTime = now;

      // Process and emit frame
      final frame = _processImage(image);
      if (!_frameStreamController.isClosed) {
        _frameStreamController.add(frame);
      }
    });
  }

  /// Stop capturing frames
  Future<void> stopCapture() async {
    if (!_isCapturing) return;

    _isCapturing = false;
    _currentFps = 0;
    await _controller?.stopImageStream();
  }

  /// Pause the camera preview
  Future<void> pausePreview() async {
    ensureInitialized();
    await _controller!.pausePreview();
    _isPaused = true;
  }

  /// Resume the camera preview
  Future<void> resumePreview() async {
    ensureInitialized();
    await _controller!.resumePreview();
    _isPaused = false;
  }

  /// Set the torch on or off
  Future<void> setTorch(bool on) async {
    ensureInitialized();
    await _controller!.setFlashMode(on ? FlashMode.torch : FlashMode.off);
    _isTorchOn = on;
  }

  /// Toggle the torch
  Future<void> toggleTorch() async {
    await setTorch(!_isTorchOn);
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    ensureInitialized();

    // Find the next camera with a different lens direction
    final currentLens = _cameras[_currentCameraIndex].lensDirection;
    final targetLens = currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final newIndex = _cameras.indexWhere(
      (c) => c.lensDirection == targetLens,
    );

    if (newIndex < 0) {
      // No other camera available
      return;
    }

    final wasCapturing = _isCapturing;

    // Stop current capture
    if (_isCapturing) {
      await stopCapture();
    }

    // Dispose current controller
    await _controller?.dispose();

    // Update index and reinitialize
    _currentCameraIndex = newIndex;
    await _initializeController();

    // Resume capture if was capturing
    if (wasCapturing) {
      await startCapture(fps: _currentFps);
    }

    // Reset torch state (may not be available on new camera)
    _isTorchOn = false;
  }

  /// Capture a single frame as JPEG bytes
  Future<Uint8List> captureFrame() async {
    ensureInitialized();

    final xFile = await _controller!.takePicture();
    return await xFile.readAsBytes();
  }

  /// Process a CameraImage into a CameraFrame
  CameraFrame _processImage(CameraImage image) {
    // Determine format based on platform
    final ImageFormat format;
    final Uint8List bytes;

    if (image.format.group == ImageFormatGroup.yuv420) {
      format = ImageFormat.yuv420;
      // Concatenate YUV planes
      bytes = _concatenateYuvPlanes(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      format = ImageFormat.bgra8888;
      bytes = image.planes[0].bytes;
    } else {
      // Default to JPEG-ish handling
      format = ImageFormat.jpeg;
      bytes = image.planes[0].bytes;
    }

    return CameraFrame(
      bytes: bytes,
      width: image.width,
      height: image.height,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      format: format,
    );
  }

  /// Concatenate YUV420 planes into a single buffer
  Uint8List _concatenateYuvPlanes(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final ySize = yPlane.bytes.length;
    final uSize = uPlane.bytes.length;
    final vSize = vPlane.bytes.length;

    final combined = Uint8List(ySize + uSize + vSize);
    combined.setRange(0, ySize, yPlane.bytes);
    combined.setRange(ySize, ySize + uSize, uPlane.bytes);
    combined.setRange(ySize + uSize, ySize + uSize + vSize, vPlane.bytes);

    return combined;
  }
}
