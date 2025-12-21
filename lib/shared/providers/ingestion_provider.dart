import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/models/guide.dart';
import '../../services/ingestion_service.dart';

part 'ingestion_provider.g.dart';

/// Status of the ingestion process
enum IngestionStatus {
  /// Ready for new input
  idle,

  /// Currently processing input
  loading,

  /// Successfully created guide
  success,

  /// Error occurred during ingestion
  error,
}

/// State for guide ingestion
class IngestionState {
  /// Current status of ingestion
  final IngestionStatus status;

  /// The resulting guide (if successful)
  final Guide? guide;

  /// Error that occurred (if any)
  final IngestionException? error;

  /// Create idle state
  const IngestionState.idle()
    : status = IngestionStatus.idle,
      guide = null,
      error = null;

  /// Create loading state
  const IngestionState.loading()
    : status = IngestionStatus.loading,
      guide = null,
      error = null;

  /// Create success state with guide
  IngestionState.success(Guide this.guide)
    : status = IngestionStatus.success,
      error = null;

  /// Create error state with exception
  IngestionState.error(IngestionException this.error)
    : status = IngestionStatus.error,
      guide = null;

  /// Whether currently loading
  bool get isLoading => status == IngestionStatus.loading;

  /// Whether an error occurred
  bool get hasError => status == IngestionStatus.error;

  /// Whether a guide was successfully created
  bool get hasGuide => guide != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngestionState &&
        other.status == status &&
        other.guide == guide &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(status, guide, error);
}

/// Notifier for managing ingestion state
@Riverpod(keepAlive: true)
class IngestionNotifier extends _$IngestionNotifier {
  /// Track the current request to cancel stale responses
  int _currentRequestId = 0;

  IngestionService get _service => ref.read(ingestionServiceProvider);

  @override
  IngestionState build() => const IngestionState.idle();

  /// Ingest content from user input
  ///
  /// Automatically detects if input is a URL or text description.
  Future<void> ingest(String input) async {
    // Increment request ID to track this specific request
    final requestId = ++_currentRequestId;

    // Set loading state
    state = const IngestionState.loading();

    try {
      final guide = await _service.ingest(input);

      // Only update state if this is still the current request
      if (requestId == _currentRequestId) {
        state = IngestionState.success(guide);
      }
    } on IngestionException catch (e) {
      if (requestId == _currentRequestId) {
        state = IngestionState.error(e);
      }
    } catch (e) {
      if (requestId == _currentRequestId) {
        // Wrap unknown exceptions
        state = IngestionState.error(
          IngestionException(
            e.toString(),
            code: 'unknown_error',
            originalError: e,
          ),
        );
      }
    }
  }

  /// Reset state to idle
  void reset() {
    _currentRequestId++;
    state = const IngestionState.idle();
  }

  /// Clear error and return to idle
  void clearError() {
    if (state.hasError) {
      state = const IngestionState.idle();
    }
  }
}
