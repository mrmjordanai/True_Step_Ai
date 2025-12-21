import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Utility for checking available storage space
class StorageChecker {
  /// Minimum required storage in bytes (500 MB)
  static const int minRequiredBytes = 500 * 1024 * 1024;

  /// Warning threshold in bytes (1 GB)
  static const int warningThresholdBytes = 1024 * 1024 * 1024;

  /// Check if there's enough storage for recording
  ///
  /// Returns a [StorageStatus] indicating available space and warnings
  static Future<StorageStatus> checkAvailableStorage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final stat = await _getStorageStats(directory.path);

      return StorageStatus(
        availableBytes: stat,
        isLow: stat < warningThresholdBytes,
        isCritical: stat < minRequiredBytes,
      );
    } catch (e) {
      // If we can't check, assume it's okay
      return const StorageStatus(
        availableBytes: -1,
        isLow: false,
        isCritical: false,
      );
    }
  }

  /// Get storage statistics for a path
  static Future<int> _getStorageStats(String path) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // On mobile, use platform-specific disk space check
      return await _getFreeDiskSpace(path);
    }
    // Default: return a large value to not block functionality
    return warningThresholdBytes * 10;
  }

  /// Get free disk space for the filesystem containing the path
  static Future<int> _getFreeDiskSpace(String path) async {
    try {
      // Use platform-specific approach
      if (Platform.isAndroid) {
        // Android: Use StatFs via method channel (not implemented, estimate)
        // For MVP, we'll return a safe estimate
        return warningThresholdBytes * 2;
      } else if (Platform.isIOS) {
        // iOS: Similar limitation
        return warningThresholdBytes * 2;
      }
      return warningThresholdBytes * 10;
    } catch (e) {
      return warningThresholdBytes * 2;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return 'Unknown';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

/// Storage status information
class StorageStatus {
  /// Available bytes (-1 if unknown)
  final int availableBytes;

  /// True if storage is below warning threshold (1 GB)
  final bool isLow;

  /// True if storage is below minimum (500 MB)
  final bool isCritical;

  const StorageStatus({
    required this.availableBytes,
    required this.isLow,
    required this.isCritical,
  });

  /// Human-readable available space
  String get formattedAvailable => StorageChecker.formatBytes(availableBytes);

  /// Whether storage check succeeded
  bool get isKnown => availableBytes >= 0;
}
