import 'package:permission_handler/permission_handler.dart';

import 'base_service.dart';

/// Permission service for handling device permissions
///
/// Manages camera, microphone, and storage permissions required
/// for session recording and voice control features.
class PermissionService extends BaseService {
  @override
  Future<void> onInitialize() async {
    // No initialization needed for permission handler
  }

  @override
  Future<void> onDispose() async {
    // No cleanup needed
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Check if both camera and microphone permissions are granted
  Future<bool> hasSessionPermissions() async {
    final camera = await hasCameraPermission();
    final microphone = await hasMicrophonePermission();
    return camera && microphone;
  }

  /// Request camera permission
  ///
  /// Returns true if permission was granted.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request microphone permission
  ///
  /// Returns true if permission was granted.
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Request both camera and microphone permissions
  ///
  /// Returns a map with the status of each permission.
  Future<Map<Permission, PermissionStatus>> requestSessionPermissions() async {
    return await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  /// Check if camera permission is permanently denied
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied;
  }

  /// Check if microphone permission is permanently denied
  Future<bool> isMicrophonePermissionPermanentlyDenied() async {
    return await Permission.microphone.isPermanentlyDenied;
  }

  /// Check if any session permission is permanently denied
  Future<bool> isAnySessionPermissionPermanentlyDenied() async {
    final camera = await isCameraPermissionPermanentlyDenied();
    final microphone = await isMicrophonePermissionPermanentlyDenied();
    return camera || microphone;
  }

  /// Open app settings for the user to manually grant permissions
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get the current status of camera permission
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// Get the current status of microphone permission
  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  /// Get detailed permission status for all session-related permissions
  Future<SessionPermissionStatus> getSessionPermissionStatus() async {
    final cameraStatus = await getCameraPermissionStatus();
    final microphoneStatus = await getMicrophonePermissionStatus();

    return SessionPermissionStatus(
      camera: cameraStatus,
      microphone: microphoneStatus,
    );
  }

  /// Check if speech recognition permission is granted (for voice commands)
  Future<bool> hasSpeechRecognitionPermission() async {
    return await Permission.speech.isGranted;
  }

  /// Request speech recognition permission
  Future<bool> requestSpeechRecognitionPermission() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }

  /// Request all permissions needed for full app functionality
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.camera,
      Permission.microphone,
      Permission.speech,
    ].request();
  }
}

/// Holds the permission status for all session-related permissions
class SessionPermissionStatus {
  final PermissionStatus camera;
  final PermissionStatus microphone;

  const SessionPermissionStatus({
    required this.camera,
    required this.microphone,
  });

  /// Whether all permissions are granted
  bool get allGranted => camera.isGranted && microphone.isGranted;

  /// Whether any permission is denied
  bool get anyDenied => camera.isDenied || microphone.isDenied;

  /// Whether any permission is permanently denied
  bool get anyPermanentlyDenied =>
      camera.isPermanentlyDenied || microphone.isPermanentlyDenied;

  /// Whether permissions need to be requested
  bool get needsRequest =>
      !camera.isGranted || !microphone.isGranted;

  /// Get a user-friendly message about the permission status
  String get statusMessage {
    if (allGranted) {
      return 'All permissions granted';
    }

    final denied = <String>[];
    if (!camera.isGranted) denied.add('camera');
    if (!microphone.isGranted) denied.add('microphone');

    if (anyPermanentlyDenied) {
      return 'Please enable ${denied.join(' and ')} in Settings';
    }

    return 'Please grant ${denied.join(' and ')} permission';
  }
}
