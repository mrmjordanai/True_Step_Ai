/// Base class for all TrueStep services
///
/// Provides a consistent interface for service lifecycle management
/// including initialization and disposal.
abstract class BaseService {
  bool _isInitialized = false;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service
  ///
  /// This method should be called before using the service.
  /// It sets up any required resources and connections.
  Future<void> initialize() async {
    if (_isInitialized) return;
    await onInitialize();
    _isInitialized = true;
  }

  /// Internal initialization logic to be implemented by subclasses
  Future<void> onInitialize();

  /// Dispose of the service and release resources
  ///
  /// This method should be called when the service is no longer needed.
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await onDispose();
    _isInitialized = false;
  }

  /// Internal disposal logic to be implemented by subclasses
  Future<void> onDispose();

  /// Ensure the service is initialized before use
  ///
  /// Throws [StateError] if the service has not been initialized.
  void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        '${runtimeType.toString()} has not been initialized. '
        'Call initialize() before using this service.',
      );
    }
  }
}
