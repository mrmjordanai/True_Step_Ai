import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/app_exception.dart';

/// Global error handler for the application
///
/// Provides centralized error handling, logging, and user-friendly
/// error message generation.
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();

  factory ErrorHandler() => _instance;

  ErrorHandler._internal();

  /// Initialize error handling for the app
  void initialize() {
    // Catch Flutter errors
    FlutterError.onError = (details) {
      _handleFlutterError(details);
    };

    // Catch async errors that aren't caught elsewhere
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }

  /// Handle and convert any error to an AppException
  AppException handle(Object error, [StackTrace? stackTrace]) {
    // Already an AppException
    if (error is AppException) {
      _logError(error, stackTrace);
      return error;
    }

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      final exception = _mapFirebaseAuthError(error);
      _logError(exception, stackTrace);
      return exception;
    }

    // Firebase errors (general)
    if (error is FirebaseException) {
      final exception = _mapFirebaseError(error);
      _logError(exception, stackTrace);
      return exception;
    }

    // Network errors
    if (_isNetworkError(error)) {
      final exception = NetworkException.noConnection();
      _logError(exception, stackTrace);
      return exception;
    }

    // Timeout errors
    if (error is TimeoutException) {
      final exception = NetworkException.timeout();
      _logError(exception, stackTrace);
      return exception;
    }

    // Generic error
    final exception = AppException(
      _getUserFriendlyMessage(error),
      originalError: error,
      stackTrace: stackTrace,
    );
    _logError(exception, stackTrace);
    return exception;
  }

  /// Run a function with error handling
  Future<T> runGuarded<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e, st) {
      throw handle(e, st);
    }
  }

  /// Run a synchronous function with error handling
  T runGuardedSync<T>(T Function() fn) {
    try {
      return fn();
    } catch (e, st) {
      throw handle(e, st);
    }
  }

  /// Map Firebase Auth errors to AuthException
  AuthException _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'wrong-password':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'invalid-email':
        return const AuthException(
          'Invalid email address.',
          code: 'invalid_email',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled.',
          code: 'user_disabled',
        );
      case 'too-many-requests':
        return AuthException.tooManyRequests();
      case 'requires-recent-login':
        return AuthException.sessionExpired();
      default:
        return AuthException(
          error.message ?? 'Authentication failed.',
          code: error.code,
          originalError: error,
        );
    }
  }

  /// Map general Firebase errors
  AppException _mapFirebaseError(FirebaseException error) {
    // Storage errors
    if (error.plugin == 'firebase_storage') {
      switch (error.code) {
        case 'object-not-found':
          return StorageException.fileNotFound();
        case 'unauthorized':
          return StorageException.permissionDenied();
        case 'quota-exceeded':
          return StorageException.quotaExceeded();
        default:
          return StorageException(
            error.message ?? 'Storage operation failed.',
            code: error.code,
            originalError: error,
          );
      }
    }

    // Default Firebase error
    return AppException(
      error.message ?? 'An error occurred.',
      code: error.code,
      originalError: error,
    );
  }

  /// Check if error is network-related
  bool _isNetworkError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('no internet') ||
        errorString.contains('failed host lookup');
  }

  /// Get a user-friendly message for unknown errors
  String _getUserFriendlyMessage(Object error) {
    final message = error.toString();

    // Don't expose technical details to users
    if (message.contains('Exception:')) {
      return 'Something went wrong. Please try again.';
    }

    // Truncate long messages
    if (message.length > 100) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  /// Log error for debugging/analytics
  void _logError(AppException exception, StackTrace? stackTrace) {
    // In debug mode, print to console
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────');
      debugPrint('│ ERROR: ${exception.message}');
      if (exception.code != null) {
        debugPrint('│ Code: ${exception.code}');
      }
      if (exception.originalError != null) {
        debugPrint('│ Original: ${exception.originalError}');
      }
      if (stackTrace != null) {
        debugPrint('│ Stack trace:');
        debugPrint(
          '│ ${stackTrace.toString().split('\n').take(5).join('\n│ ')}',
        );
      }
      debugPrint('└─────────────────────────────────────────────');
    }

    // Report to Firebase Crashlytics in release mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        exception.originalError ?? exception,
        stackTrace,
        reason: exception.message,
        fatal: false,
      );
    }
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  }

  /// Handle platform errors (async errors not caught elsewhere)
  void _handlePlatformError(Object error, StackTrace stack) {
    _logError(
      AppException(
        'Unhandled error: $error',
        originalError: error,
        stackTrace: stack,
      ),
      stack,
    );
  }
}

/// Global error handler instance
final errorHandler = ErrorHandler();

/// Extension for easy error handling on futures
extension ErrorHandlingExtension<T> on Future<T> {
  /// Handle errors and convert to AppException
  Future<T> handleErrors() async {
    try {
      return await this;
    } catch (e, st) {
      throw errorHandler.handle(e, st);
    }
  }
}
