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
class VerificationResult {
  /// Whether the step was verified as complete
  final bool verified;

  /// Confidence score from 0.0 to 1.0
  final double confidence;

  /// Issue description if not verified
  final String? issue;

  /// Whether a safety alert was triggered
  final bool safetyAlert;

  /// Suggestion for fixing the issue
  final String? suggestion;

  /// Timestamp of the verification
  final DateTime timestamp;

  const VerificationResult({
    required this.verified,
    required this.confidence,
    this.issue,
    this.safetyAlert = false,
    this.suggestion,
    required this.timestamp,
  });

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

  /// Create a copy with modified fields
  VerificationResult copyWith({
    bool? verified,
    double? confidence,
    String? issue,
    bool? safetyAlert,
    String? suggestion,
    DateTime? timestamp,
  }) {
    return VerificationResult(
      verified: verified ?? this.verified,
      confidence: confidence ?? this.confidence,
      issue: issue ?? this.issue,
      safetyAlert: safetyAlert ?? this.safetyAlert,
      suggestion: suggestion ?? this.suggestion,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      'confidence': confidence,
      'issue': issue,
      'safetyAlert': safetyAlert,
      'suggestion': suggestion,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      verified: json['verified'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      issue: json['issue'] as String?,
      safetyAlert: json['safetyAlert'] as bool? ?? false,
      suggestion: json['suggestion'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationResult &&
        other.verified == verified &&
        other.confidence == confidence &&
        other.issue == issue &&
        other.safetyAlert == safetyAlert &&
        other.suggestion == suggestion;
  }

  @override
  int get hashCode {
    return Object.hash(verified, confidence, issue, safetyAlert, suggestion);
  }

  @override
  String toString() {
    return 'VerificationResult(verified: $verified, confidence: $confidence, '
        'issue: $issue, safetyAlert: $safetyAlert)';
  }
}
