import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/services/network_monitor.dart';

void main() {
  group('NetworkStatus', () {
    test('has all expected values', () {
      expect(NetworkStatus.values.length, 3);
      expect(NetworkStatus.connected, isNotNull);
      expect(NetworkStatus.disconnected, isNotNull);
      expect(NetworkStatus.unknown, isNotNull);
    });
  });

  group('NetworkMonitor', () {
    late NetworkMonitor monitor;

    setUp(() {
      monitor = NetworkMonitor();
    });

    tearDown(() {
      monitor.dispose();
    });

    test('initial status is unknown', () {
      expect(monitor.status, NetworkStatus.unknown);
    });

    test('isConnected is false when unknown', () {
      expect(monitor.isConnected, false);
    });

    test('checkConnection returns current status', () {
      expect(monitor.checkConnection(), false);
    });

    test('statusStream is a broadcast stream', () {
      expect(monitor.statusStream.isBroadcast, true);
    });
  });
}
