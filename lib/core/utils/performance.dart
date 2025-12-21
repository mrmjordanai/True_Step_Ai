import 'dart:async';

import 'package:flutter/foundation.dart';

/// Utility for measuring and optimizing startup performance
class StartupProfiler {
  static final StartupProfiler _instance = StartupProfiler._internal();
  factory StartupProfiler() => _instance;
  StartupProfiler._internal();

  final Map<String, Duration> _measurements = {};
  DateTime? _startTime;

  /// Mark the start of app initialization
  void markStart() {
    _startTime = DateTime.now();
    _log('App startup began');
  }

  /// Mark a milestone in the startup process
  void markMilestone(String name) {
    if (_startTime == null) return;
    final elapsed = DateTime.now().difference(_startTime!);
    _measurements[name] = elapsed;
    _log('$name: ${elapsed.inMilliseconds}ms');
  }

  /// Mark the app as fully loaded
  void markComplete() {
    markMilestone('Complete');
    _printSummary();
  }

  /// Get total startup time in milliseconds
  int get totalStartupMs {
    final complete = _measurements['Complete'];
    return complete?.inMilliseconds ?? 0;
  }

  /// Check if startup was slow (>3 seconds)
  bool get wasStartupSlow => totalStartupMs > 3000;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[StartupProfiler] $message');
    }
  }

  void _printSummary() {
    if (!kDebugMode) return;

    debugPrint('╔══════════════════════════════════════════╗');
    debugPrint('║         STARTUP PERFORMANCE              ║');
    debugPrint('╠══════════════════════════════════════════╣');

    _measurements.forEach((name, duration) {
      final ms = duration.inMilliseconds.toString().padLeft(5);
      debugPrint('║ $name: ${ms}ms'.padRight(43) + '║');
    });

    final status = wasStartupSlow ? '⚠️ SLOW' : '✅ FAST';
    debugPrint('╠══════════════════════════════════════════╣');
    debugPrint('║ Status: $status'.padRight(43) + '║');
    debugPrint('╚══════════════════════════════════════════╝');
  }

  /// Reset for testing
  void reset() {
    _measurements.clear();
    _startTime = null;
  }
}

/// Singleton instance
final startupProfiler = StartupProfiler();

/// Throttles function calls to prevent rapid-fire execution
class Throttle {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttle(this.duration);

  /// Execute the function if not throttled
  void call(VoidCallback fn) {
    if (_isThrottled) return;

    _isThrottled = true;
    fn();

    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  /// Cancel pending throttle
  void cancel() {
    _timer?.cancel();
    _isThrottled = false;
  }
}

/// Debounces function calls to wait for inactivity
class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce(this.duration);

  /// Execute the function after the duration of inactivity
  void call(VoidCallback fn) {
    _timer?.cancel();
    _timer = Timer(duration, fn);
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
  }
}

/// Rate limiter for API calls
class RateLimiter {
  final int maxCalls;
  final Duration window;
  final List<DateTime> _timestamps = [];

  RateLimiter({required this.maxCalls, required this.window});

  /// Check if a call is allowed
  bool get canCall {
    _cleanOldTimestamps();
    return _timestamps.length < maxCalls;
  }

  /// Record a call
  void recordCall() {
    _timestamps.add(DateTime.now());
  }

  /// Try to make a call, returns true if allowed
  bool tryCall() {
    if (canCall) {
      recordCall();
      return true;
    }
    return false;
  }

  /// Time until next call is allowed
  Duration get timeUntilNextCall {
    if (canCall) return Duration.zero;
    _cleanOldTimestamps();
    if (_timestamps.isEmpty) return Duration.zero;

    final oldestRelevant = _timestamps.first;
    final expiresAt = oldestRelevant.add(window);
    return expiresAt.difference(DateTime.now());
  }

  void _cleanOldTimestamps() {
    final cutoff = DateTime.now().subtract(window);
    _timestamps.removeWhere((t) => t.isBefore(cutoff));
  }

  /// Reset the limiter
  void reset() {
    _timestamps.clear();
  }
}
