import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../core/models/session.dart';
import 'base_service.dart';
import 'camera_service.dart';

/// Local recording data before upload
class LocalRecordingData {
  /// Path to full session video
  final String fullSessionPath;

  /// Duration in seconds
  final int durationSeconds;

  /// Paths to per-step clips (stepIndex -> path)
  final Map<int, String> stepClipPaths;

  const LocalRecordingData({
    required this.fullSessionPath,
    required this.durationSeconds,
    this.stepClipPaths = const {},
  });
}

/// Service for recording session videos
///
/// Uses the camera package's native video recording capabilities.
/// Handles:
/// - Full session recording
/// - Per-step verification clips
/// - Upload to Firebase Storage
class RecordingService extends BaseService {
  CameraService? _cameraService;
  FirebaseStorage? _storage;

  /// Current session being recorded
  String? _currentSessionId;

  /// Whether recording is active
  bool _isRecording = false;

  /// Whether recording is paused
  bool _isPaused = false;

  /// Start time of current recording
  DateTime? _recordingStartTime;

  /// Paths to step clips for current session
  final Map<int, String> _stepClipPaths = {};

  /// Current recording file path
  String? _currentRecordingPath;

  /// Temporary directory for recordings
  Directory? _recordingDir;

  /// Inject dependencies
  void setServices({CameraService? cameraService, FirebaseStorage? storage}) {
    _cameraService = cameraService;
    _storage = storage ?? FirebaseStorage.instance;
  }

  @override
  Future<void> onInitialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _recordingDir = Directory(p.join(appDir.path, 'recordings'));
    if (!await _recordingDir!.exists()) {
      await _recordingDir!.create(recursive: true);
    }
  }

  @override
  Future<void> onDispose() async {
    if (_isRecording) {
      await stopRecording();
    }
  }

  /// Whether recording is currently active
  bool get isRecording => _isRecording;

  /// Whether recording is paused
  bool get isPaused => _isPaused;

  /// Current session ID being recorded
  String? get currentSessionId => _currentSessionId;

  /// Get the session recording directory
  Future<Directory> _getSessionDir(String sessionId) async {
    final dir = Directory(p.join(_recordingDir!.path, sessionId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Start recording a session
  Future<void> startRecording(String sessionId) async {
    ensureInitialized();

    if (_isRecording) {
      throw StateError('Recording already in progress');
    }

    if (_cameraService == null || !_cameraService!.isInitialized) {
      throw StateError('Camera service not available');
    }

    _currentSessionId = sessionId;
    _stepClipPaths.clear();

    // Create session directory
    final sessionDir = await _getSessionDir(sessionId);
    _currentRecordingPath = p.join(sessionDir.path, 'session.mp4');

    // Start video recording using camera
    await _cameraService!.controller!.startVideoRecording();

    _isRecording = true;
    _isPaused = false;
    _recordingStartTime = DateTime.now();
  }

  /// Stop recording and save the video
  Future<LocalRecordingData?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      // Stop recording
      final xFile = await _cameraService!.controller!.stopVideoRecording();

      // Calculate duration
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 0;

      // Move to final location
      final file = File(xFile.path);
      if (_currentRecordingPath != null) {
        await file.copy(_currentRecordingPath!);
        await file.delete();
      }

      _isRecording = false;
      _isPaused = false;

      return LocalRecordingData(
        fullSessionPath: _currentRecordingPath!,
        durationSeconds: duration,
        stepClipPaths: Map.from(_stepClipPaths),
      );
    } catch (e) {
      _isRecording = false;
      _isPaused = false;
      rethrow;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) return;

    await _cameraService!.controller!.pauseVideoRecording();
    _isPaused = true;
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) return;

    await _cameraService!.controller!.resumeVideoRecording();
    _isPaused = false;
  }

  /// Save a verification clip for a step
  ///
  /// This captures a still image as a "clip" since true video clipping
  /// requires post-processing. For MVP, we capture a verification snapshot.
  Future<String?> saveStepClip(int stepIndex) async {
    if (!_isRecording || _currentSessionId == null) return null;

    try {
      final sessionDir = await _getSessionDir(_currentSessionId!);
      final clipPath = p.join(sessionDir.path, 'clips', 'step_$stepIndex.jpg');

      // Ensure clips directory exists
      final clipsDir = Directory(p.dirname(clipPath));
      if (!await clipsDir.exists()) {
        await clipsDir.create(recursive: true);
      }

      // Capture a frame as the step verification image
      final bytes = await _cameraService!.captureFrame();
      await File(clipPath).writeAsBytes(bytes);

      _stepClipPaths[stepIndex] = clipPath;
      return clipPath;
    } catch (e) {
      return null;
    }
  }

  /// Upload recording to Firebase Storage
  Future<Recording?> uploadRecording(
    String userId,
    String sessionId,
    LocalRecordingData localData,
  ) async {
    ensureInitialized();

    if (_storage == null) {
      throw StateError('Firebase Storage not available');
    }

    try {
      // Upload full session video
      final sessionFile = File(localData.fullSessionPath);
      if (!await sessionFile.exists()) {
        return null;
      }

      final fullSessionRef = _storage!.ref(
        'recordings/$userId/$sessionId/session.mp4',
      );
      await fullSessionRef.putFile(sessionFile);
      final fullSessionUrl = await fullSessionRef.getDownloadURL();

      // Upload step clips
      final stepClipUrls = <int, String>{};
      for (final entry in localData.stepClipPaths.entries) {
        final clipFile = File(entry.value);
        if (await clipFile.exists()) {
          final clipRef = _storage!.ref(
            'recordings/$userId/$sessionId/clips/step_${entry.key}.jpg',
          );
          await clipRef.putFile(clipFile);
          stepClipUrls[entry.key] = await clipRef.getDownloadURL();
        }
      }

      // Get file size
      final sizeBytes = await sessionFile.length();

      return Recording(
        fullSessionUrl: fullSessionUrl,
        durationSeconds: localData.durationSeconds,
        sizeBytes: sizeBytes,
        retentionDays: 30,
        stepClipUrls: stepClipUrls,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Clean up local recording files for a session
  Future<void> cleanupLocalRecording(String sessionId) async {
    try {
      final sessionDir = await _getSessionDir(sessionId);
      if (await sessionDir.exists()) {
        await sessionDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}

/// Provider for RecordingService
final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(() => service.dispose());
  return service;
});
