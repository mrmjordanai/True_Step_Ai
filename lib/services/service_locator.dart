import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'storage_service.dart';
import 'permission_service.dart';

// Re-export the camera and voice providers from feature folders
export '../features/session/providers/camera_provider.dart';
export '../features/session/providers/voice_provider.dart';

/// Service providers for dependency injection via Riverpod
///
/// All services are provided as singletons and initialized lazily.

/// Provides the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides the storage service for Firebase Storage operations
final storageServiceProvider = Provider<StorageService>((ref) {
  final service = StorageService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides the permission service for handling device permissions
final permissionServiceProvider = Provider<PermissionService>((ref) {
  final service = PermissionService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for authentication state changes
final authStateProvider = StreamProvider<dynamic>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for checking if user is signed in
final isSignedInProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isSignedIn;
});

/// Provider for current user ID (null if not signed in)
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser?.uid;
});

/// Provider for session permission status
final sessionPermissionStatusProvider = FutureProvider<SessionPermissionStatus>((ref) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.getSessionPermissionStatus();
});

/// Provider for checking if all session permissions are granted
final hasSessionPermissionsProvider = FutureProvider<bool>((ref) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.hasSessionPermissions();
});

/// Initialize all services
///
/// Call this during app startup to initialize services that require it.
Future<void> initializeServices(ProviderContainer container) async {
  final authService = container.read(authServiceProvider);
  final storageService = container.read(storageServiceProvider);
  final permissionService = container.read(permissionServiceProvider);

  await Future.wait([
    authService.initialize(),
    storageService.initialize(),
    permissionService.initialize(),
  ]);
}

/// Extension on WidgetRef for convenient service access
extension ServiceRefExtension on WidgetRef {
  /// Get the auth service
  AuthService get authService => read(authServiceProvider);

  /// Get the storage service
  StorageService get storageService => read(storageServiceProvider);

  /// Get the permission service
  PermissionService get permissionService => read(permissionServiceProvider);
}
