import '../../../core/models/guide.dart';
import 'session_state.dart';

/// Complete session data including guide, progress, and results
///
/// This is the main state object managed by SessionNotifier.
class SessionData {
  /// The guide being executed
  final Guide guide;

  /// Current session lifecycle phase
  final SessionPhase phase;

  /// Traffic light state (only relevant when phase == active)
  final SentinelState sentinelState;

  /// Current step index (0-based)
  final int currentStepIndex;

  /// Total elapsed time in seconds
  final int elapsedSeconds;

  /// Per-step verification results (stepIndex -> result)
  final Map<int, VerificationResult> stepResults;

  /// Number of interventions triggered during session
  final int interventionCount;

  /// Whether recording is active
  final bool isRecording;

  /// Current intervention message (when sentinelState == intervention)
  final String? interventionMessage;

  /// Timestamp when session started
  final DateTime startTime;

  /// Whether calibration was skipped
  final bool calibrationSkipped;

  /// Tools that have been checked off
  final Set<String> checkedTools;

  const SessionData({
    required this.guide,
    this.phase = SessionPhase.calibrating,
    this.sentinelState = SentinelState.watching,
    this.currentStepIndex = 0,
    this.elapsedSeconds = 0,
    this.stepResults = const {},
    this.interventionCount = 0,
    this.isRecording = false,
    this.interventionMessage,
    required this.startTime,
    this.calibrationSkipped = false,
    this.checkedTools = const {},
  });

  /// Create initial session data for a guide
  factory SessionData.start(Guide guide) {
    return SessionData(guide: guide, startTime: DateTime.now());
  }

  // Computed properties

  /// Current step being executed
  GuideStep get currentStep => guide.steps[currentStepIndex];

  /// Whether currently on the last step
  bool get isLastStep => currentStepIndex >= guide.steps.length - 1;

  /// Whether currently on the first step
  bool get isFirstStep => currentStepIndex <= 0;

  /// Progress percentage (0.0 to 1.0)
  double get progressPercent =>
      guide.steps.isEmpty ? 0.0 : (currentStepIndex + 1) / guide.steps.length;

  /// Number of steps completed (verified)
  int get stepsCompleted => stepResults.values.where((r) => r.verified).length;

  /// Average confidence score across verified steps
  double get averageConfidence {
    final verified = stepResults.values.where((r) => r.verified).toList();
    if (verified.isEmpty) return 0.0;
    return verified.map((r) => r.confidence).reduce((a, b) => a + b) /
        verified.length;
  }

  /// Whether the session is in an active state (not paused/completed/cancelled)
  bool get isActive =>
      phase == SessionPhase.active ||
      phase == SessionPhase.calibrating ||
      phase == SessionPhase.toolAudit;

  /// Whether all required tools are checked
  bool get allToolsChecked {
    final requiredTools = guide.steps.expand((step) => step.tools).toSet();
    return requiredTools.every((tool) => checkedTools.contains(tool));
  }

  /// Create a copy with modified fields
  ///
  /// To clear interventionMessage to null, set [clearInterventionMessage] to true.
  SessionData copyWith({
    Guide? guide,
    SessionPhase? phase,
    SentinelState? sentinelState,
    int? currentStepIndex,
    int? elapsedSeconds,
    Map<int, VerificationResult>? stepResults,
    int? interventionCount,
    bool? isRecording,
    String? interventionMessage,
    bool clearInterventionMessage = false,
    DateTime? startTime,
    bool? calibrationSkipped,
    Set<String>? checkedTools,
  }) {
    return SessionData(
      guide: guide ?? this.guide,
      phase: phase ?? this.phase,
      sentinelState: sentinelState ?? this.sentinelState,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      stepResults: stepResults ?? this.stepResults,
      interventionCount: interventionCount ?? this.interventionCount,
      isRecording: isRecording ?? this.isRecording,
      interventionMessage: clearInterventionMessage
          ? null
          : (interventionMessage ?? this.interventionMessage),
      startTime: startTime ?? this.startTime,
      calibrationSkipped: calibrationSkipped ?? this.calibrationSkipped,
      checkedTools: checkedTools ?? this.checkedTools,
    );
  }

  /// Create a copy with intervention message cleared
  SessionData clearIntervention() {
    return copyWith(
      clearInterventionMessage: true,
      sentinelState: SentinelState.watching,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionData &&
        other.guide == guide &&
        other.phase == phase &&
        other.sentinelState == sentinelState &&
        other.currentStepIndex == currentStepIndex &&
        other.elapsedSeconds == elapsedSeconds &&
        other.interventionCount == interventionCount &&
        other.isRecording == isRecording &&
        other.interventionMessage == interventionMessage &&
        other.calibrationSkipped == calibrationSkipped;
  }

  @override
  int get hashCode {
    return Object.hash(
      guide,
      phase,
      sentinelState,
      currentStepIndex,
      elapsedSeconds,
      interventionCount,
      isRecording,
      interventionMessage,
      calibrationSkipped,
    );
  }

  @override
  String toString() {
    return 'SessionData(phase: $phase, sentinel: $sentinelState, '
        'step: ${currentStepIndex + 1}/${guide.steps.length}, '
        'elapsed: ${elapsedSeconds}s)';
  }
}

/// Summary of a completed session
class SessionSummary {
  /// The guide that was executed
  final Guide guide;

  /// Total duration in seconds
  final int totalDurationSeconds;

  /// Number of steps completed
  final int stepsCompleted;

  /// Total number of steps
  final int totalSteps;

  /// Number of interventions triggered
  final int interventionCount;

  /// Average AI confidence score
  final double averageConfidence;

  /// Whether session was completed (vs cancelled)
  final bool wasCompleted;

  /// Session start time
  final DateTime startTime;

  /// Session end time
  final DateTime endTime;

  /// Per-step results
  final Map<int, VerificationResult> stepResults;

  const SessionSummary({
    required this.guide,
    required this.totalDurationSeconds,
    required this.stepsCompleted,
    required this.totalSteps,
    required this.interventionCount,
    required this.averageConfidence,
    required this.wasCompleted,
    required this.startTime,
    required this.endTime,
    this.stepResults = const {},
  });

  /// Create summary from session data
  factory SessionSummary.fromSession(SessionData session) {
    final endTime = DateTime.now();
    return SessionSummary(
      guide: session.guide,
      totalDurationSeconds: session.elapsedSeconds,
      stepsCompleted: session.stepsCompleted,
      totalSteps: session.guide.steps.length,
      interventionCount: session.interventionCount,
      averageConfidence: session.averageConfidence,
      wasCompleted: session.phase == SessionPhase.completed,
      startTime: session.startTime,
      endTime: endTime,
      stepResults: session.stepResults,
    );
  }

  /// Completion percentage
  double get completionPercent =>
      totalSteps == 0 ? 0.0 : stepsCompleted / totalSteps;

  /// Format duration as "Xm Ys"
  String get formattedDuration {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  String toString() {
    return 'SessionSummary(completed: $wasCompleted, '
        'steps: $stepsCompleted/$totalSteps, '
        'duration: $formattedDuration, '
        'interventions: $interventionCount)';
  }
}
