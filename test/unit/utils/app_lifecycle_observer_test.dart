import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/utils/app_lifecycle_observer.dart';

void main() {
  group('AppLifecycleObserver', () {
    late AppLifecycleObserver observer;

    setUp(() {
      observer = AppLifecycleObserver();
    });

    tearDown(() {
      observer.dispose();
    });

    test('can add and remove listeners', () {
      final listener = _TestListener();

      observer.addListener(listener);
      expect(true, true); // No error thrown

      observer.removeListener(listener);
      expect(true, true); // No error thrown
    });

    test('notifies listeners on state change', () {
      final listener = _TestListener();
      observer.addListener(listener);

      // Simulate state change
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(listener.pausedCount, 1);

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(listener.resumedCount, 1);
    });
  });

  group('SessionLifecycleMixin', () {
    test('calls session methods on relevant lifecycle events', () {
      final handler = _TestSessionHandler();

      // Simulate having active session
      handler.hasActiveSession = true;

      // Simulate lifecycle events directly
      handler.onPaused();
      expect(handler.sessionPauseCount, 1);

      handler.onResumed();
      expect(handler.sessionResumeCount, 1);
    });

    test('skips session methods when no active session', () {
      final handler = _TestSessionHandler();
      handler.hasActiveSession = false;

      handler.onPaused();
      expect(handler.sessionPauseCount, 0);

      handler.onResumed();
      expect(handler.sessionResumeCount, 0);
    });
  });
}

class _TestListener extends TrueStepLifecycleListener {
  int resumedCount = 0;
  int pausedCount = 0;

  @override
  void onResumed() => resumedCount++;

  @override
  void onPaused() => pausedCount++;
}

class _TestSessionHandler extends TrueStepLifecycleListener
    with SessionLifecycleMixin {
  @override
  bool hasActiveSession = false;

  int sessionPauseCount = 0;
  int sessionResumeCount = 0;

  @override
  void onSessionPause() => sessionPauseCount++;

  @override
  void onSessionResume() => sessionResumeCount++;
}
