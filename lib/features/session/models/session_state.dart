import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';
part 'session_state.g.dart';

/// Session state enums and models for TrueStep
///
/// Defines the Sentinel (Traffic Light) state machine and session lifecycle.

/// Traffic light states for visual feedback during verification
enum SentinelState {
  /// GREEN - On-device monitoring active, watching for triggers
  watching,

  /// YELLOW - Sending frame to AI for verification
  verifying,

  /// RED - Error or safety issue detected, requires user action
  intervention,
}

/// Session lifecycle phases
enum SessionPhase {
  /// Initial calibration (optional camera setup)
  calibrating,

  /// Tool check before starting the session
  toolAudit,

  /// Actively executing steps
  active,

  /// User paused the session
  paused,

  /// All steps completed successfully
  completed,

  /// Session cancelled/abandoned by user
  cancelled,
}

/// Result of an AI verification attempt
@freezed
class VerificationResult with _$VerificationResult {
  const VerificationResult._();

  const factory VerificationResult({
    /// Whether the step was verified as complete
    required bool verified,

    /// Confidence score from 0.0 to 1.0
    required double confidence,

    /// Issue description if not verified
    String? issue,

    /// Whether a safety alert was triggered
    @Default(false) bool safetyAlert,

    /// Suggestion for fixing the issue
    String? suggestion,

    /// Timestamp of the verification
    required DateTime timestamp,
  }) = _VerificationResult;

  /// Create a successful verification result
  factory VerificationResult.success({
    double confidence = 0.95,
    DateTime? timestamp,
  }) {
    return VerificationResult(
      verified: true,
      confidence: confidence,
      safetyAlert: false,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Create a failed verification result
  factory VerificationResult.failure({
    required String issue,
    double confidence = 0.3,
    bool safetyAlert = false,
    String? suggestion,
    DateTime? timestamp,
  }) {
    return VerificationResult(
      verified: false,
      confidence: confidence,
      issue: issue,
      safetyAlert: safetyAlert,
      suggestion: suggestion,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) =>
      _$VerificationResultFromJson(json);
}
