import '../exceptions/app_exception.dart';

/// Result type for operations that can succeed or fail
///
/// Use this instead of throwing exceptions for expected failure cases.
/// This makes error handling explicit and type-safe.
///
/// Example:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.getUser(id);
///     return Success(user);
///   } catch (e) {
///     return Failure(NetworkException('Failed to fetch user'));
///   }
/// }
///
/// // Usage:
/// final result = await getUser('123');
/// switch (result) {
///   case Success(:final data):
///     print('Got user: ${data.name}');
///   case Failure(:final exception):
///     print('Error: ${exception.message}');
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Whether this result is a success
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data if success, or null if failure
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// Get the exception if failure, or null if success
  AppException? get exceptionOrNull => switch (this) {
        Success() => null,
        Failure(:final exception) => exception,
      };

  /// Transform the data if success
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Success(transform(data)),
        Failure(:final exception) => Failure(exception),
      };

  /// Transform the data if success (async)
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async =>
      switch (this) {
        Success(:final data) => Success(await transform(data)),
        Failure(:final exception) => Failure(exception),
      };

  /// Transform the result if success
  Result<R> flatMap<R>(Result<R> Function(T data) transform) => switch (this) {
        Success(:final data) => transform(data),
        Failure(:final exception) => Failure(exception),
      };

  /// Execute a callback if success
  void onSuccess(void Function(T data) callback) {
    if (this case Success(:final data)) {
      callback(data);
    }
  }

  /// Execute a callback if failure
  void onFailure(void Function(AppException exception) callback) {
    if (this case Failure(:final exception)) {
      callback(exception);
    }
  }

  /// Execute callbacks for both success and failure
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        Failure(:final exception) => failure(exception),
      };

  /// Get the data or throw the exception
  T getOrThrow() => switch (this) {
        Success(:final data) => data,
        Failure(:final exception) => throw exception,
      };

  /// Get the data or return a default value
  T getOrDefault(T defaultValue) => switch (this) {
        Success(:final data) => data,
        Failure() => defaultValue,
      };

  /// Get the data or compute a default value
  T getOrElse(T Function() orElse) => switch (this) {
        Success(:final data) => data,
        Failure() => orElse(),
      };
}

/// Successful result containing data
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Failed result containing an exception
final class Failure<T> extends Result<T> {
  final AppException exception;

  const Failure(this.exception);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;

  @override
  int get hashCode => exception.hashCode;

  @override
  String toString() => 'Failure($exception)';
}

/// Extension to convert a Future to a Result
extension FutureResultExtension<T> on Future<T> {
  /// Execute the future and wrap the result
  Future<Result<T>> toResult({
    AppException Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      return Success(await this);
    } catch (e, st) {
      if (onError != null) {
        return Failure(onError(e, st));
      }
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(AppException(
        e.toString(),
        originalError: e,
        stackTrace: st,
      ));
    }
  }
}

/// Helper function to run a callback and wrap the result
Future<Result<T>> runCatching<T>(Future<T> Function() block) async {
  try {
    return Success(await block());
  } catch (e, st) {
    if (e is AppException) {
      return Failure(e);
    }
    return Failure(AppException(
      e.toString(),
      originalError: e,
      stackTrace: st,
    ));
  }
}

/// Helper function for synchronous operations
Result<T> runCatchingSync<T>(T Function() block) {
  try {
    return Success(block());
  } catch (e, st) {
    if (e is AppException) {
      return Failure(e);
    }
    return Failure(AppException(
      e.toString(),
      originalError: e,
      stackTrace: st,
    ));
  }
}
