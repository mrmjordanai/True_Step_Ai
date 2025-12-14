import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:truestep/services/auth_service.dart';
import 'package:truestep/services/permission_service.dart';
import 'package:truestep/services/storage_service.dart';

// ============================================
// MOCK SERVICES
// ============================================

/// Mock AuthService for testing
class MockAuthService extends Mock implements AuthService {}

/// Mock PermissionService for testing
class MockPermissionService extends Mock implements PermissionService {}

/// Mock StorageService for testing
class MockStorageService extends Mock implements StorageService {}

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

// ============================================
// SETUP HELPERS
// ============================================

/// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(FakeSessionPermissionStatus());
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
