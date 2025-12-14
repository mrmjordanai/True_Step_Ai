/// Base exception class for all application-specific exceptions
///
/// Provides a consistent error structure with message, code, and
/// optional original error for debugging.
class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String? code;

  /// Original exception that caused this error
  final dynamic originalError;

  /// Stack trace from the original error
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// No internet connection
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection. Please check your network settings.',
      code: 'no_connection',
    );
  }

  /// Request timeout
  factory NetworkException.timeout() {
    return const NetworkException(
      'Request timed out. Please try again.',
      code: 'timeout',
    );
  }

  /// Server error
  factory NetworkException.serverError([String? details]) {
    return NetworkException(
      details ?? 'Server error. Please try again later.',
      code: 'server_error',
    );
  }
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Invalid credentials
  factory AuthException.invalidCredentials() {
    return const AuthException(
      'Invalid email or password.',
      code: 'invalid_credentials',
    );
  }

  /// User not found
  factory AuthException.userNotFound() {
    return const AuthException(
      'No account found with this email.',
      code: 'user_not_found',
    );
  }

  /// Email already in use
  factory AuthException.emailInUse() {
    return const AuthException(
      'An account already exists with this email.',
      code: 'email_in_use',
    );
  }

  /// Weak password
  factory AuthException.weakPassword() {
    return const AuthException(
      'Password is too weak. Use at least 8 characters.',
      code: 'weak_password',
    );
  }

  /// User not signed in
  factory AuthException.notSignedIn() {
    return const AuthException(
      'You must be signed in to perform this action.',
      code: 'not_signed_in',
    );
  }

  /// Session expired
  factory AuthException.sessionExpired() {
    return const AuthException(
      'Your session has expired. Please sign in again.',
      code: 'session_expired',
    );
  }

  /// Too many requests
  factory AuthException.tooManyRequests() {
    return const AuthException(
      'Too many attempts. Please try again later.',
      code: 'too_many_requests',
    );
  }
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// File not found
  factory StorageException.fileNotFound() {
    return const StorageException(
      'File not found.',
      code: 'file_not_found',
    );
  }

  /// Upload failed
  factory StorageException.uploadFailed([String? details]) {
    return StorageException(
      details ?? 'Failed to upload file. Please try again.',
      code: 'upload_failed',
    );
  }

  /// Download failed
  factory StorageException.downloadFailed([String? details]) {
    return StorageException(
      details ?? 'Failed to download file. Please try again.',
      code: 'download_failed',
    );
  }

  /// Storage quota exceeded
  factory StorageException.quotaExceeded() {
    return const StorageException(
      'Storage quota exceeded.',
      code: 'quota_exceeded',
    );
  }

  /// Permission denied
  factory StorageException.permissionDenied() {
    return const StorageException(
      'You do not have permission to access this file.',
      code: 'permission_denied',
    );
  }
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Camera permission denied
  factory PermissionException.cameradenied() {
    return const PermissionException(
      'Camera permission is required to record sessions.',
      code: 'camera_denied',
    );
  }

  /// Microphone permission denied
  factory PermissionException.microphoneDeniewd() {
    return const PermissionException(
      'Microphone permission is required for voice commands.',
      code: 'microphone_denied',
    );
  }

  /// Permission permanently denied
  factory PermissionException.permanentlyDenied(String permission) {
    return PermissionException(
      '$permission permission was denied. Please enable it in Settings.',
      code: 'permanently_denied',
    );
  }
}

/// Camera-related exceptions
class CameraException extends AppException {
  const CameraException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Camera not available
  factory CameraException.notAvailable() {
    return const CameraException(
      'Camera is not available on this device.',
      code: 'not_available',
    );
  }

  /// Camera initialization failed
  factory CameraException.initializationFailed([String? details]) {
    return CameraException(
      details ?? 'Failed to initialize camera. Please try again.',
      code: 'initialization_failed',
    );
  }

  /// Recording failed
  factory CameraException.recordingFailed([String? details]) {
    return CameraException(
      details ?? 'Failed to record video. Please try again.',
      code: 'recording_failed',
    );
  }

  /// Camera in use
  factory CameraException.inUse() {
    return const CameraException(
      'Camera is being used by another application.',
      code: 'in_use',
    );
  }
}

/// AI/ML service exceptions
class AIException extends AppException {
  const AIException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Model not available
  factory AIException.modelNotAvailable() {
    return const AIException(
      'AI model is not available. Please try again later.',
      code: 'model_not_available',
    );
  }

  /// Analysis failed
  factory AIException.analysisFailed([String? details]) {
    return AIException(
      details ?? 'Failed to analyze image. Please try again.',
      code: 'analysis_failed',
    );
  }

  /// Rate limit exceeded
  factory AIException.rateLimited() {
    return const AIException(
      'Too many requests. Please wait a moment and try again.',
      code: 'rate_limited',
    );
  }

  /// Invalid input
  factory AIException.invalidInput([String? details]) {
    return AIException(
      details ?? 'Invalid input for AI analysis.',
      code: 'invalid_input',
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  /// Field that failed validation
  final String? field;

  const ValidationException(
    super.message, {
    this.field,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  /// Required field is empty
  factory ValidationException.required(String field) {
    return ValidationException(
      '$field is required.',
      field: field,
      code: 'required',
    );
  }

  /// Invalid format
  factory ValidationException.invalidFormat(String field, [String? expected]) {
    return ValidationException(
      expected != null
          ? '$field has invalid format. Expected: $expected'
          : '$field has invalid format.',
      field: field,
      code: 'invalid_format',
    );
  }

  /// Value out of range
  factory ValidationException.outOfRange(String field, num min, num max) {
    return ValidationException(
      '$field must be between $min and $max.',
      field: field,
      code: 'out_of_range',
    );
  }
}
