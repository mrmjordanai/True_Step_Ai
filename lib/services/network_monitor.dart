import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity status
enum NetworkStatus {
  /// Device is connected to the internet
  connected,

  /// Device has no internet connection
  disconnected,

  /// Connection status is unknown
  unknown,
}

/// Service for monitoring network connectivity
///
/// Provides real-time updates on network status and helpers
/// for graceful degradation when offline.
class NetworkMonitor {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  final _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// Current network status
  NetworkStatus get status => _currentStatus;

  /// Whether currently connected
  bool get isConnected => _currentStatus == NetworkStatus.connected;

  /// Stream of network status changes
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  /// Initialize and start monitoring
  Future<void> initialize() async {
    // Get initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  /// Update status based on connectivity results
  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );

    final newStatus = hasConnection
        ? NetworkStatus.connected
        : NetworkStatus.disconnected;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  /// Check connectivity synchronously (uses cached value)
  bool checkConnection() => isConnected;

  /// Check connectivity asynchronously (fresh check)
  Future<bool> checkConnectionAsync() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return isConnected;
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Provider for NetworkMonitor
final networkMonitorProvider = Provider<NetworkMonitor>((ref) {
  final monitor = NetworkMonitor();
  ref.onDispose(() => monitor.dispose());
  return monitor;
});

/// Provider for network status stream
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final monitor = ref.watch(networkMonitorProvider);
  return monitor.statusStream;
});

/// Provider for current connection status
final isConnectedProvider = Provider<bool>((ref) {
  final monitor = ref.watch(networkMonitorProvider);
  return monitor.isConnected;
});
