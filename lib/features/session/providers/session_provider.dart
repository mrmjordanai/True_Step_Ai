import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/guide.dart';
import '../../../services/camera_service.dart';
import '../../../services/voice_service.dart';
import '../models/session_command.dart';
import '../models/session_data.dart';
import '../models/session_state.dart';

/// Provider for the current active session
///
/// Returns null if no session is active.
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionData?>((
  ref,
) {
  return SessionNotifier();
});

/// State notifier for managing session lifecycle and Sentinel state machine
///
/// Handles the complete session flow:
/// 1. Calibration (optional)
/// 2. Tool Audit
/// 3. Active step execution with Traffic Light verification
/// 4. Completion/Cancellation
class SessionNotifier extends StateNotifier<SessionData?> {
  SessionNotifier() : super(null);

  Timer? _elapsedTimer;
  CameraService? _cameraService; // Used in Phase 1.7 for frame capture
  VoiceService? _voiceService;

  /// Inject services for testing
  void setServices({CameraService? cameraService, VoiceService? voiceService}) {
    _cameraService = cameraService;
    _voiceService = voiceService;
  }

  /// Start a new session with the given guide
  Future<void> startSession(Guide guide) async {
    // Cancel any existing session
    if (state != null) {
      await cancelSession();
    }

    state = SessionData.start(guide);
    _startElapsedTimer();
  }

  /// Complete calibration and proceed to tool audit
  void completeCalibration() {
    if (state == null) return;
    if (state!.phase != SessionPhase.calibrating) return;

    state = state!.copyWith(
      phase: SessionPhase.toolAudit,
      calibrationSkipped: false,
    );
  }

  /// Skip calibration with acknowledgment
  void skipCalibration() {
    if (state == null) return;
    if (state!.phase != SessionPhase.calibrating) return;

    state = state!.copyWith(
      phase: SessionPhase.toolAudit,
      calibrationSkipped: true,
    );
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
    if (state!.phase != SessionPhase.toolAudit) return;

    state = state!.copyWith(
      phase: SessionPhase.active,
      sentinelState: SentinelState.watching,
    );

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
      // TODO: Replace with real AI verification in Phase 1.7
      final result = await _mockVerification();

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
          );
          _stopElapsedTimer();
        } else {
          // Advance to next step
          state = state!.copyWith(
            stepResults: newResults,
            sentinelState: SentinelState.watching,
            currentStepIndex: state!.currentStepIndex + 1,
          );
          _speakCurrentInstruction();
        }
      } else {
        // Verification failed - transition to RED
        state = state!.copyWith(
          sentinelState: SentinelState.intervention,
          interventionMessage: result.issue ?? 'Step not complete',
          interventionCount: state!.interventionCount + 1,
        );
      }
    } catch (e) {
      // Error during verification - stay on current step
      state = state!.copyWith(
        sentinelState: SentinelState.intervention,
        interventionMessage: 'Verification error: $e',
        interventionCount: state!.interventionCount + 1,
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
      clearInterventionMessage: true,
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
      clearInterventionMessage: true,
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
    if (state!.phase != SessionPhase.active) return;

    state = state!.copyWith(phase: SessionPhase.paused);
    _stopElapsedTimer();
  }

  /// Resume from paused state
  void resumeSession() {
    if (state == null) return;
    if (state!.phase != SessionPhase.paused) return;

    state = state!.copyWith(phase: SessionPhase.active);
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
      clearInterventionMessage: true,
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
  SessionSummary? completeSession() {
    if (state == null) return null;

    _stopElapsedTimer();
    state = state!.copyWith(phase: SessionPhase.completed);

    final summary = SessionSummary.fromSession(state!);
    return summary;
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

  /// Mock verification for Phase 1.6 testing
  ///
  /// Will be replaced with real Gemini AI in Phase 1.7
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

  @override
  void dispose() {
    _stopElapsedTimer();
    super.dispose();
  }
}
