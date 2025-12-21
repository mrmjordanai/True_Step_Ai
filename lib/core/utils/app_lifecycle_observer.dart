import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Observer for app lifecycle events
///
/// Monitors when the app is backgrounded/resumed and notifies
/// relevant services to pause/resume operations.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final List<TrueStepLifecycleListener> _listeners = [];

  /// Register a listener for lifecycle events
  void addListener(TrueStepLifecycleListener listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(TrueStepLifecycleListener listener) {
    _listeners.remove(listener);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    for (final listener in _listeners) {
      switch (state) {
        case AppLifecycleState.resumed:
          listener.onResumed();
          break;
        case AppLifecycleState.inactive:
          listener.onInactive();
          break;
        case AppLifecycleState.paused:
          listener.onPaused();
          break;
        case AppLifecycleState.detached:
          listener.onDetached();
          break;
        case AppLifecycleState.hidden:
          listener.onHidden();
          break;
      }
    }
  }

  /// Initialize and start observing
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Clean up
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {
      // Binding may not be initialized (e.g., in tests)
    }
    _listeners.clear();
  }
}

/// Interface for receiving lifecycle events
abstract class TrueStepLifecycleListener {
  /// App returned to foreground
  void onResumed() {}

  /// App is partially visible (e.g., incoming call)
  void onInactive() {}

  /// App is in background
  void onPaused() {}

  /// App is detached from the view
  void onDetached() {}

  /// App is hidden (iOS only)
  void onHidden() {}
}

/// Provider for AppLifecycleObserver
final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  final observer = AppLifecycleObserver();
  // Note: initialize() should be called after WidgetsFlutterBinding is initialized
  // This is typically done in main.dart
  ref.onDispose(() => observer.dispose());
  return observer;
});

/// Mixin for session-aware lifecycle handling
mixin SessionLifecycleMixin on TrueStepLifecycleListener {
  bool get hasActiveSession;

  void onSessionPause();
  void onSessionResume();

  @override
  void onResumed() {
    if (hasActiveSession) {
      onSessionResume();
    }
  }

  @override
  void onPaused() {
    if (hasActiveSession) {
      onSessionPause();
    }
  }
}
