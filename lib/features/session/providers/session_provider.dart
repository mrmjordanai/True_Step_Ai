import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/guide.dart';
import '../../../core/models/session.dart' as session_model;
import '../../../repositories/session_repository.dart';
import '../../../services/ai_service.dart';
import '../../../services/camera_service.dart';
import '../../../services/recording_service.dart';
import '../../../services/voice_service.dart';
import '../models/session_command.dart';
import '../models/session_data.dart';
import '../models/session_state.dart';

part 'session_provider.g.dart';

/// Maximum number of verification retries before showing manual skip option
const int maxVerificationRetries = 3;

/// Valid state transitions for the session state machine
///
/// This defines the allowed phase transitions to prevent invalid states.
const Map<SessionPhase, Set<SessionPhase>> _validPhaseTransitions = {
  SessionPhase.calibrating: {SessionPhase.toolAudit, SessionPhase.cancelled},
  SessionPhase.toolAudit: {SessionPhase.active, SessionPhase.cancelled},
  SessionPhase.active: {
    SessionPhase.paused,
    SessionPhase.completed,
    SessionPhase.cancelled,
  },
  SessionPhase.paused: {SessionPhase.active, SessionPhase.cancelled},
  SessionPhase.completed: <SessionPhase>{}, // Terminal state
  SessionPhase.cancelled: <SessionPhase>{}, // Terminal state
};

/// State notifier for managing session lifecycle and Sentinel state machine
///
/// Handles the complete session flow:
/// 1. Calibration (optional)
/// 2. Tool Audit
/// 3. Active step execution with Traffic Light verification
/// 4. Completion/Cancellation
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionData? build() {
    ref.onDispose(_stopElapsedTimer);
    return null;
  }

  Timer? _elapsedTimer;
  CameraService? _cameraService;
  VoiceService? _voiceService;
  AIService? _aiService;
  RecordingService? _recordingService;
  SessionRepository? _sessionRepository;

  /// Whether to use mock verification (for testing without Firebase)
  bool _useMockVerification = false;

  /// Whether recording is enabled for this session
  bool _recordingEnabled = false;

  /// User ID for session persistence
  String? _userId;

  /// Check if a phase transition is valid
  bool _canTransitionTo(SessionPhase newPhase) {
    if (state == null) return false;
    final currentPhase = state!.phase;
    return _validPhaseTransitions[currentPhase]?.contains(newPhase) ?? false;
  }

  /// Transition to a new phase with validation
  ///
  /// Returns true if transition was successful, false if invalid.
  /// In debug mode, asserts on invalid transitions.
  bool _transitionTo(SessionPhase newPhase) {
    if (state == null) return false;

    if (!_canTransitionTo(newPhase)) {
      // In debug mode, assert to catch bugs early
      assert(
        false,
        'Invalid session phase transition: ${state!.phase} → $newPhase',
      );
      return false;
    }

    state = state!.copyWith(phase: newPhase);
    return true;
  }

  /// Inject services for testing
  void setServices({
    CameraService? cameraService,
    VoiceService? voiceService,
    AIService? aiService,
    RecordingService? recordingService,
    SessionRepository? sessionRepository,
    bool useMockVerification = false,
    bool recordingEnabled = false,
    String? userId,
  }) {
    _cameraService = cameraService;
    _voiceService = voiceService;
    _aiService = aiService;
    _recordingService = recordingService;
    _sessionRepository = sessionRepository;
    _useMockVerification = useMockVerification;
    _recordingEnabled = recordingEnabled;
    _userId = userId;
  }

  /// Start a new session with the given guide
  Future<void> startSession(Guide guide, {String? inputMethod}) async {
    // Cancel any existing session
    if (state != null) {
      await cancelSession();
    }

    state = SessionData.start(guide);
    _startElapsedTimer();

    // Start recording if enabled
    if (_recordingEnabled && _recordingService != null) {
      try {
        final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
        await _recordingService!.startRecording(sessionId);
      } catch (e) {
        // Recording failed to start, continue without recording
      }
    }
  }

  /// Complete calibration and proceed to tool audit
  void completeCalibration() {
    if (state == null) return;
    if (!_transitionTo(SessionPhase.toolAudit)) return;

    state = state!.copyWith(calibrationSkipped: false);
  }

  /// Skip calibration with acknowledgment
  void skipCalibration() {
    if (state == null) return;
    if (!_transitionTo(SessionPhase.toolAudit)) return;

    state = state!.copyWith(calibrationSkipped: true);
  }

  /// Toggle a tool's checked state
  void toggleTool(String tool) {
    if (state == null) return;

    final newChecked = Set<String>.from(state!.checkedTools);
    if (newChecked.contains(tool)) {
      newChecked.remove(tool);
    } else {
      newChecked.add(tool);
    }

    state = state!.copyWith(checkedTools: newChecked);
  }

  /// Mark all tools as ready and proceed to active session
  void confirmToolsReady() {
    if (state == null) return;
    if (!_transitionTo(SessionPhase.active)) return;

    state = state!.copyWith(sentinelState: SentinelState.watching);

    // Speak the first instruction
    _speakCurrentInstruction();
  }

  /// Trigger verification for current step
  ///
  /// Transitions: watching -> verifying -> watching/intervention
  Future<void> triggerVerification() async {
    if (state == null) return;
    if (state!.phase != SessionPhase.active) return;
    if (state!.sentinelState != SentinelState.watching) return;

    // Transition to YELLOW (verifying)
    state = state!.copyWith(sentinelState: SentinelState.verifying);

    try {
      // Use mock or real AI verification
      final result = _useMockVerification || _aiService == null
          ? await _mockVerification()
          : await _verifyWithAI();

      if (result.verified) {
        // Step verified - record and advance
        final newResults = Map<int, VerificationResult>.from(
          state!.stepResults,
        );
        newResults[state!.currentStepIndex] = result;

        if (state!.isLastStep) {
          // Session complete!
          state = state!.copyWith(
            stepResults: newResults,
            sentinelState: SentinelState.watching,
            phase: SessionPhase.completed,
            currentStepRetryCount: 0,
            showManualSkipOption: false,
          );
          _stopElapsedTimer();
        } else {
          // Advance to next step
          state = state!.copyWith(
            stepResults: newResults,
            sentinelState: SentinelState.watching,
            currentStepIndex: state!.currentStepIndex + 1,
            currentStepRetryCount: 0,
            showManualSkipOption: false,
          );
          _speakCurrentInstruction();
        }
      } else {
        // Verification failed - handle with retry logic
        _handleVerificationFailure(result);
      }
    } catch (e) {
      // Error during verification - treat as failure
      _handleVerificationFailure(
        VerificationResult.failure(issue: 'Verification error: $e'),
      );
    }
  }

  /// Handle verification failure with retry logic
  void _handleVerificationFailure(VerificationResult result) {
    final retryCount = state!.currentStepRetryCount + 1;

    if (retryCount >= maxVerificationRetries) {
      // Max retries reached - show manual skip option
      state = state!.copyWith(
        sentinelState: SentinelState.intervention,
        interventionMessage:
            'Unable to verify after $retryCount attempts. You can manually confirm or retry.',
        interventionCount: state!.interventionCount + 1,
        currentStepRetryCount: retryCount,
        showManualSkipOption: true,
      );
    } else {
      // Still has retries - show intervention
      state = state!.copyWith(
        sentinelState: SentinelState.intervention,
        interventionMessage: result.issue ?? 'Step not complete',
        interventionCount: state!.interventionCount + 1,
        currentStepRetryCount: retryCount,
      );
    }
  }

  /// Advance to next step (manual navigation)
  void nextStep() {
    if (state == null) return;
    if (state!.phase != SessionPhase.active) return;
    if (state!.isLastStep) return;

    state = state!.copyWith(
      currentStepIndex: state!.currentStepIndex + 1,
      sentinelState: SentinelState.watching,
      interventionMessage: null,
    );

    _speakCurrentInstruction();
  }

  /// Go back to previous step
  void previousStep() {
    if (state == null) return;
    if (state!.phase != SessionPhase.active) return;
    if (state!.isFirstStep) return;

    state = state!.copyWith(
      currentStepIndex: state!.currentStepIndex - 1,
      sentinelState: SentinelState.watching,
      interventionMessage: null,
    );

    _speakCurrentInstruction();
  }

  /// Repeat current step instruction via TTS
  void repeatInstruction() {
    _speakCurrentInstruction();
  }

  /// Handle a voice command
  void handleCommand(SessionCommand command) {
    switch (command) {
      case SessionCommand.nextStep:
        if (state?.phase == SessionPhase.active &&
            state?.sentinelState == SentinelState.watching) {
          triggerVerification();
        }
        break;
      case SessionCommand.previousStep:
        previousStep();
        break;
      case SessionCommand.repeatInstruction:
        repeatInstruction();
        break;
      case SessionCommand.previewNext:
        // TODO: Implement preview
        break;
      case SessionCommand.pause:
        pauseSession();
        break;
      case SessionCommand.resume:
        resumeSession();
        break;
      case SessionCommand.stop:
        // Handled at UI level with confirmation
        break;
      case SessionCommand.help:
        // TODO: Implement help
        break;
      case SessionCommand.skip:
        skipStep();
        break;
    }
  }

  /// Pause the session
  void pauseSession() {
    if (state == null) return;
    if (!_transitionTo(SessionPhase.paused)) return;

    _stopElapsedTimer();
  }

  /// Resume from paused state
  void resumeSession() {
    if (state == null) return;
    if (!_transitionTo(SessionPhase.active)) return;

    _startElapsedTimer();
  }

  /// Handle intervention resolution
  void resolveIntervention({bool reVerify = true}) {
    if (state == null) return;
    if (state!.sentinelState != SentinelState.intervention) return;

    state = state!.clearIntervention();

    if (reVerify) {
      triggerVerification();
    }
  }

  /// Skip current step with warning acknowledged
  void skipStep() {
    if (state == null) return;
    if (state!.phase != SessionPhase.active) return;

    // Clear any intervention
    state = state!.copyWith(
      interventionMessage: null,
      sentinelState: SentinelState.watching,
    );

    if (state!.isLastStep) {
      // Complete session (with skipped last step)
      state = state!.copyWith(phase: SessionPhase.completed);
      _stopElapsedTimer();
    } else {
      // Advance without recording verification
      state = state!.copyWith(currentStepIndex: state!.currentStepIndex + 1);
      _speakCurrentInstruction();
    }
  }

  /// End session and return final summary
  Future<SessionSummary?> completeSession() async {
    if (state == null) return null;

    _stopElapsedTimer();
    state = state!.copyWith(phase: SessionPhase.completed);

    final summary = SessionSummary.fromSession(state!);

    // Stop recording and save
    await _finalizeRecordingAndSave(summary);

    return summary;
  }

  /// Finalize recording and save session to Firestore
  Future<void> _finalizeRecordingAndSave(SessionSummary summary) async {
    session_model.Recording? recording;

    // Stop recording if active
    if (_recordingService != null && _recordingService!.isRecording) {
      try {
        final localData = await _recordingService!.stopRecording();
        if (localData != null && _userId != null) {
          recording = await _recordingService!.uploadRecording(
            _userId!,
            _recordingService!.currentSessionId ?? 'unknown',
            localData,
          );
        }
      } catch (e) {
        // Recording finalization failed, continue without
      }
    }

    // Save session to Firestore
    if (_sessionRepository != null && _userId != null) {
      try {
        final session = session_model.Session(
          sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
          userId: _userId!,
          guideId: summary.guide.guideId,
          guideTitle: summary.guide.title,
          inputMethod: summary.guide.sourceUrl != null
              ? session_model.InputMethod.url
              : session_model.InputMethod.text,
          startedAt: summary.startTime,
          completedAt: summary.endTime,
          expiresAt: summary.startTime.add(const Duration(days: 30)),
          totalSteps: summary.totalSteps,
          stepsCompleted: summary.stepsCompleted,
          recording: recording,
          stepLogs: _buildStepLogs(summary),
          interventionCount: summary.interventionCount,
          averageConfidence: summary.averageConfidence,
        );
        await _sessionRepository!.saveSession(session);
      } catch (e) {
        // Session save failed, continue
      }
    }
  }

  /// Build step logs from session summary
  List<session_model.StepLog> _buildStepLogs(SessionSummary summary) {
    return summary.stepResults.entries.map((entry) {
      final result = entry.value;
      return session_model.StepLog(
        stepIndex: entry.key,
        verified: result.verified,
        confidence: result.confidence,
        durationSeconds: 0, // Would need per-step timing
        safetyAlert: result.safetyAlert,
        completedAt: result.timestamp,
      );
    }).toList();
  }

  /// Cancel/abandon session
  Future<void> cancelSession() async {
    if (state == null) return;

    _stopElapsedTimer();
    state = state!.copyWith(phase: SessionPhase.cancelled);
    state = null;
  }

  /// Clear session (same as cancel but synchronous)
  void clearSession() {
    _stopElapsedTimer();
    state = null;
  }

  // Private helpers

  void _startElapsedTimer() {
    _stopElapsedTimer();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state != null &&
          state!.isActive &&
          state!.phase != SessionPhase.paused) {
        state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
      }
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _speakCurrentInstruction() {
    if (state == null) return;
    if (_voiceService == null) return;

    final step = state!.currentStep;
    _voiceService!.speak(step.instruction);
  }

  /// Mock verification for testing without Firebase
  ///
  /// Used when _useMockVerification is true or _aiService is null
  Future<VerificationResult> _mockVerification() async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // 80% success rate for testing
    final success = Random().nextDouble() > 0.2;

    if (success) {
      return VerificationResult.success(
        confidence: 0.85 + Random().nextDouble() * 0.15,
      );
    } else {
      return VerificationResult.failure(
        issue: 'Step appears incomplete. Please verify and try again.',
        confidence: 0.3 + Random().nextDouble() * 0.2,
        suggestion: 'Make sure the action is clearly visible to the camera.',
      );
    }
  }

  /// Real AI verification using Gemini
  Future<VerificationResult> _verifyWithAI() async {
    if (_cameraService == null) {
      return VerificationResult.failure(issue: 'Camera not available');
    }
    if (_aiService == null) {
      return VerificationResult.failure(issue: 'AI service not available');
    }

    // Capture frame from camera (returns Uint8List directly)
    final imageBytes = await _cameraService!.captureFrame();

    // Verify with AI
    final response = await _aiService!.verifyStep(
      imageBytes: imageBytes,
      stepTitle: state!.currentStep.title,
      successCriteria: state!.currentStep.successCriteria,
    );

    // Convert AI response to VerificationResult
    if (response.verified) {
      return VerificationResult.success(confidence: response.confidence);
    } else {
      return VerificationResult.failure(
        issue: response.issue ?? 'Step not complete',
        confidence: response.confidence,
        suggestion: response.suggestion,
        safetyAlert: response.safetyAlert,
      );
    }
  }

}
