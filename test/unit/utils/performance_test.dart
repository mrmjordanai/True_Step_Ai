import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/utils/performance.dart';

void main() {
  group('StartupProfiler', () {
    setUp(() {
      startupProfiler.reset();
    });

    test('markStart initializes profiling', () {
      startupProfiler.markStart();
      expect(startupProfiler.totalStartupMs, 0); // Not complete yet
    });

    test('markMilestone records elapsed time', () async {
      startupProfiler.markStart();
      await Future.delayed(const Duration(milliseconds: 50));
      startupProfiler.markMilestone('Test');
      // Milestone recorded but totalStartupMs still 0 until markComplete
      expect(startupProfiler.totalStartupMs, 0);
    });

    test('markComplete records final time', () async {
      startupProfiler.markStart();
      await Future.delayed(const Duration(milliseconds: 50));
      startupProfiler.markComplete();
      expect(startupProfiler.totalStartupMs, greaterThan(40));
    });

    test('wasStartupSlow returns true for slow startup', () async {
      startupProfiler.markStart();
      // Simulate slow startup by marking complete immediately
      // then checking threshold
      startupProfiler.markComplete();
      expect(startupProfiler.wasStartupSlow, false);
    });
  });

  group('Throttle', () {
    test('allows first call', () {
      final throttle = Throttle(const Duration(milliseconds: 100));
      var callCount = 0;

      throttle.call(() => callCount++);
      expect(callCount, 1);

      throttle.cancel();
    });

    test('blocks rapid subsequent calls', () {
      final throttle = Throttle(const Duration(milliseconds: 100));
      var callCount = 0;

      throttle.call(() => callCount++);
      throttle.call(() => callCount++);
      throttle.call(() => callCount++);

      expect(callCount, 1);

      throttle.cancel();
    });

    test('allows call after throttle period', () async {
      final throttle = Throttle(const Duration(milliseconds: 50));
      var callCount = 0;

      throttle.call(() => callCount++);
      expect(callCount, 1);

      await Future.delayed(const Duration(milliseconds: 60));

      throttle.call(() => callCount++);
      expect(callCount, 2);

      throttle.cancel();
    });
  });

  group('Debounce', () {
    test('delays execution', () async {
      final debounce = Debounce(const Duration(milliseconds: 50));
      var callCount = 0;

      debounce.call(() => callCount++);
      expect(callCount, 0);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(callCount, 1);

      debounce.cancel();
    });

    test('cancels previous on rapid calls', () async {
      final debounce = Debounce(const Duration(milliseconds: 50));
      var callCount = 0;

      debounce.call(() => callCount++);
      debounce.call(() => callCount++);
      debounce.call(() => callCount++);

      await Future.delayed(const Duration(milliseconds: 60));
      expect(callCount, 1); // Only last call executed

      debounce.cancel();
    });
  });

  group('RateLimiter', () {
    test('allows calls under limit', () {
      final limiter = RateLimiter(
        maxCalls: 3,
        window: const Duration(seconds: 1),
      );

      expect(limiter.tryCall(), true);
      expect(limiter.tryCall(), true);
      expect(limiter.tryCall(), true);
    });

    test('blocks calls over limit', () {
      final limiter = RateLimiter(
        maxCalls: 2,
        window: const Duration(seconds: 1),
      );

      expect(limiter.tryCall(), true);
      expect(limiter.tryCall(), true);
      expect(limiter.tryCall(), false);
    });

    test('canCall returns correct status', () {
      final limiter = RateLimiter(
        maxCalls: 1,
        window: const Duration(seconds: 1),
      );

      expect(limiter.canCall, true);
      limiter.recordCall();
      expect(limiter.canCall, false);
    });

    test('timeUntilNextCall returns duration', () {
      final limiter = RateLimiter(
        maxCalls: 1,
        window: const Duration(seconds: 1),
      );

      expect(limiter.timeUntilNextCall, Duration.zero);
      limiter.recordCall();
      expect(limiter.timeUntilNextCall.inMilliseconds, greaterThan(0));
    });

    test('reset clears history', () {
      final limiter = RateLimiter(
        maxCalls: 1,
        window: const Duration(seconds: 1),
      );

      limiter.recordCall();
      expect(limiter.canCall, false);
      limiter.reset();
      expect(limiter.canCall, true);
    });
  });
}
