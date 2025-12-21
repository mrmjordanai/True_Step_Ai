import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/core/utils/storage_checker.dart';

void main() {
  group('StorageStatus', () {
    test('isKnown returns true for positive bytes', () {
      const status = StorageStatus(
        availableBytes: 1000000,
        isLow: false,
        isCritical: false,
      );
      expect(status.isKnown, true);
    });

    test('isKnown returns false for negative bytes', () {
      const status = StorageStatus(
        availableBytes: -1,
        isLow: false,
        isCritical: false,
      );
      expect(status.isKnown, false);
    });

    test('formattedAvailable formats bytes correctly', () {
      const status = StorageStatus(
        availableBytes: 1024 * 1024 * 500, // 500 MB
        isLow: false,
        isCritical: false,
      );
      expect(status.formattedAvailable, '500.0 MB');
    });
  });

  group('StorageChecker', () {
    test('formatBytes handles various sizes', () {
      expect(StorageChecker.formatBytes(0), 'Unknown');
      expect(StorageChecker.formatBytes(1024), '1.0 KB');
      expect(StorageChecker.formatBytes(1024 * 1024), '1.0 MB');
      expect(StorageChecker.formatBytes(1024 * 1024 * 1024), '1.0 GB');
    });

    test('formatBytes handles edge cases', () {
      expect(StorageChecker.formatBytes(-100), 'Unknown');
      expect(StorageChecker.formatBytes(512), '512.0 B');
    });

    test('minRequiredBytes is 500 MB', () {
      expect(StorageChecker.minRequiredBytes, 500 * 1024 * 1024);
    });

    test('warningThresholdBytes is 1 GB', () {
      expect(StorageChecker.warningThresholdBytes, 1024 * 1024 * 1024);
    });
  });
}
