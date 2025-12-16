import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:camera/camera.dart' hide ImageFormat;
import 'package:truestep/services/auth_service.dart';
import 'package:truestep/services/permission_service.dart';
import 'package:truestep/services/storage_service.dart';
import 'package:truestep/services/camera_service.dart';
import 'package:truestep/services/voice_service.dart';
import 'package:truestep/features/session/models/session_command.dart';

// ============================================
// MOCK SERVICES
// ============================================

/// Mock AuthService for testing
class MockAuthService extends Mock implements AuthService {}

/// Mock PermissionService for testing
class MockPermissionService extends Mock implements PermissionService {}

/// Mock StorageService for testing
class MockStorageService extends Mock implements StorageService {}

/// Mock CameraService for testing
class MockCameraService extends Mock implements CameraService {}

/// Mock VoiceService for testing
class MockVoiceService extends Mock implements VoiceService {}

// ============================================
// MOCK FIREBASE TYPES
// ============================================

/// Mock Firebase User
class MockFirebaseUser extends Mock implements firebase_auth.User {}

/// Mock Firebase UserCredential
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

// ============================================
// FAKE CLASSES FOR FALLBACK VALUES
// ============================================

/// Fake SessionPermissionStatus for fallback
class FakeSessionPermissionStatus extends Fake
    implements SessionPermissionStatus {
  @override
  bool get allGranted => true;

  @override
  bool get anyDenied => false;

  @override
  bool get anyPermanentlyDenied => false;

  @override
  bool get needsRequest => false;

  @override
  String get statusMessage => 'All permissions granted';
}

/// Fake CameraFrame for fallback
class FakeCameraFrame extends Fake implements CameraFrame {
  @override
  Uint8List get bytes => Uint8List(0);

  @override
  int get width => 640;

  @override
  int get height => 480;

  @override
  int get timestamp => DateTime.now().millisecondsSinceEpoch;

  @override
  ImageFormat get format => ImageFormat.jpeg;
}

/// Fake VoiceTranscript for fallback
class FakeVoiceTranscript extends Fake implements VoiceTranscript {
  @override
  String get text => '';

  @override
  double get confidence => 1.0;

  @override
  bool get isFinal => true;

  @override
  DateTime get timestamp => DateTime.now();
}

// ============================================
// SETUP HELPERS
// ============================================

/// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(FakeSessionPermissionStatus());
  registerFallbackValue(FakeCameraFrame());
  registerFallbackValue(FakeVoiceTranscript());
  registerFallbackValue(SessionCommand.nextStep);
}

/// Creates a mock AuthService with default stubs
MockAuthService createMockAuthService({
  bool isSignedIn = false,
  String? userId,
}) {
  final mockAuth = MockAuthService();

  when(() => mockAuth.isSignedIn).thenReturn(isSignedIn);
  when(() => mockAuth.currentUser).thenReturn(null);

  if (isSignedIn && userId != null) {
    final mockUser = MockFirebaseUser();
    when(() => mockUser.uid).thenReturn(userId);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  }

  return mockAuth;
}

/// Creates a mock PermissionService with default stubs
MockPermissionService createMockPermissionService({
  bool cameraGranted = false,
  bool microphoneGranted = false,
  bool notificationGranted = false,
}) {
  final mockPermission = MockPermissionService();

  when(() => mockPermission.hasCameraPermission())
      .thenAnswer((_) async => cameraGranted);
  when(() => mockPermission.hasMicrophonePermission())
      .thenAnswer((_) async => microphoneGranted);
  when(() => mockPermission.hasNotificationPermission())
      .thenAnswer((_) async => notificationGranted);
  when(() => mockPermission.requestCameraPermission())
      .thenAnswer((_) async => cameraGranted);
  when(() => mockPermission.requestMicrophonePermission())
      .thenAnswer((_) async => microphoneGranted);
  when(() => mockPermission.requestNotificationPermission())
      .thenAnswer((_) async => notificationGranted);
  when(() => mockPermission.isCameraPermissionPermanentlyDenied())
      .thenAnswer((_) async => false);
  when(() => mockPermission.isMicrophonePermissionPermanentlyDenied())
      .thenAnswer((_) async => false);
  when(() => mockPermission.isNotificationPermissionPermanentlyDenied())
      .thenAnswer((_) async => false);

  return mockPermission;
}

/// Creates a mock CameraService with default stubs
MockCameraService createMockCameraService({
  bool isInitialized = true,
  bool isCapturing = false,
  bool isTorchOn = false,
  bool isPaused = false,
  int currentFps = 30,
  CameraLensDirection currentLens = CameraLensDirection.back,
}) {
  final mockCamera = MockCameraService();

  when(() => mockCamera.isInitialized).thenReturn(isInitialized);
  when(() => mockCamera.isCapturing).thenReturn(isCapturing);
  when(() => mockCamera.isTorchOn).thenReturn(isTorchOn);
  when(() => mockCamera.isPaused).thenReturn(isPaused);
  when(() => mockCamera.currentFps).thenReturn(currentFps);
  when(() => mockCamera.currentLens).thenReturn(currentLens);
  when(() => mockCamera.frameStream)
      .thenAnswer((_) => const Stream<CameraFrame>.empty());

  when(() => mockCamera.initialize()).thenAnswer((_) async {});
  when(() => mockCamera.dispose()).thenAnswer((_) async {});
  when(() => mockCamera.startCapture(fps: any(named: 'fps')))
      .thenAnswer((_) async {});
  when(() => mockCamera.stopCapture()).thenAnswer((_) async {});
  when(() => mockCamera.pausePreview()).thenAnswer((_) async {});
  when(() => mockCamera.resumePreview()).thenAnswer((_) async {});
  when(() => mockCamera.setTorch(any())).thenAnswer((_) async {});
  when(() => mockCamera.toggleTorch()).thenAnswer((_) async {});
  when(() => mockCamera.switchCamera()).thenAnswer((_) async {});
  when(() => mockCamera.captureFrame())
      .thenAnswer((_) async => Uint8List(0));

  return mockCamera;
}

/// Creates a mock VoiceService with default stubs
MockVoiceService createMockVoiceService({
  bool isInitialized = true,
  bool isListening = false,
  bool isSpeaking = false,
  String lastTranscript = '',
}) {
  final mockVoice = MockVoiceService();

  when(() => mockVoice.isInitialized).thenReturn(isInitialized);
  when(() => mockVoice.isListening).thenReturn(isListening);
  when(() => mockVoice.isSpeaking).thenReturn(isSpeaking);
  when(() => mockVoice.lastTranscript).thenReturn(lastTranscript);
  when(() => mockVoice.transcriptStream)
      .thenAnswer((_) => const Stream<VoiceTranscript>.empty());

  when(() => mockVoice.initialize()).thenAnswer((_) async {});
  when(() => mockVoice.dispose()).thenAnswer((_) async {});
  when(() => mockVoice.startListening()).thenAnswer((_) async {});
  when(() => mockVoice.stopListening()).thenAnswer((_) async {});
  when(() => mockVoice.speak(any())).thenAnswer((_) async {});
  when(() => mockVoice.stopSpeaking()).thenAnswer((_) async {});
  when(() => mockVoice.setVolume(any())).thenAnswer((_) async {});
  when(() => mockVoice.setSpeechRate(any())).thenAnswer((_) async {});
  when(() => mockVoice.parseCommand(any())).thenReturn(null);

  return mockVoice;
}
