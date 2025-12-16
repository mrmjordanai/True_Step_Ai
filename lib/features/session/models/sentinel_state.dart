/// Sentinel (Traffic Light) states for visual verification feedback.
///
/// These states represent the AI monitoring status during an active session:
/// - GREEN (watching): On-device monitoring, waiting for user action
/// - YELLOW (verifying): Sending frame to AI for verification
/// - RED (intervention): Error or danger detected, requires user action
enum SentinelState {
  /// GREEN state - On-device monitoring active, waiting for trigger.
  ///
  /// Visual: Eye icon + pulse animation + "Watching..."
  watching,

  /// YELLOW state - Sending frame to AI for verification.
  ///
  /// Visual: Waveform + processing animation + "Verifying..."
  verifying,

  /// RED state - Error or danger detected, requires user action.
  ///
  /// Visual: Stop hand + shake animation + "STOP"
  intervention,
}

/// Extension methods for [SentinelState].
extension SentinelStateX on SentinelState {
  /// Whether this state represents a blocking condition (user must act).
  bool get isBlocking => this == SentinelState.intervention;

  /// Whether the AI is actively processing in this state.
  bool get isProcessing => this == SentinelState.verifying;

  /// Whether the system is passively monitoring.
  bool get isMonitoring => this == SentinelState.watching;

  /// User-facing label for this state.
  String get label {
    switch (this) {
      case SentinelState.watching:
        return 'Watching...';
      case SentinelState.verifying:
        return 'Verifying...';
      case SentinelState.intervention:
        return 'STOP';
    }
  }
}

/// Session lifecycle phases.
///
/// Represents the current phase of a session from start to completion.
enum SessionPhase {
  /// Initial calibration (optional, can be skipped).
  calibrating,

  /// Tool check before starting the session.
  toolAudit,

  /// Active step execution with AI monitoring.
  active,

  /// User paused the session.
  paused,

  /// All steps completed successfully.
  completed,

  /// Session cancelled/abandoned by user.
  cancelled,
}

/// Extension methods for [SessionPhase].
extension SessionPhaseX on SessionPhase {
  /// Whether this phase is a terminal state (session ended).
  bool get isTerminal =>
      this == SessionPhase.completed || this == SessionPhase.cancelled;

  /// Whether the session is currently active (not paused or ended).
  bool get isActive =>
      this == SessionPhase.active ||
      this == SessionPhase.calibrating ||
      this == SessionPhase.toolAudit;

  /// Whether voice commands should be listened to in this phase.
  bool get acceptsVoiceCommands =>
      this == SessionPhase.active || this == SessionPhase.paused;

  /// User-facing label for this phase.
  String get label {
    switch (this) {
      case SessionPhase.calibrating:
        return 'Calibrating';
      case SessionPhase.toolAudit:
        return 'Tool Check';
      case SessionPhase.active:
        return 'In Progress';
      case SessionPhase.paused:
        return 'Paused';
      case SessionPhase.completed:
        return 'Completed';
      case SessionPhase.cancelled:
        return 'Cancelled';
    }
  }
}
