/// Guide difficulty levels
enum GuideDifficulty {
  easy,
  medium,
  hard;

  /// Parse difficulty from string (case-insensitive)
  static GuideDifficulty? fromString(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    for (final difficulty in GuideDifficulty.values) {
      if (difficulty.name == lower) return difficulty;
    }
    return null;
  }
}

/// Guide category types
enum GuideCategory {
  culinary,
  diy;

  /// Parse category from string (case-insensitive)
  static GuideCategory? fromString(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    for (final category in GuideCategory.values) {
      if (category.name == lower) return category;
    }
    return null;
  }
}

/// A single step within a guide
///
/// Each step represents an action the user should perform,
/// along with criteria for visual verification.
class GuideStep {
  /// Unique identifier for this step within the guide
  final int stepId;

  /// Brief title of the step
  final String title;

  /// Detailed instruction text
  final String instruction;

  /// Criteria for visual verification (what should be visible when complete)
  final String successCriteria;

  /// Optional reference image URL for comparison
  final String? referenceImageUrl;

  /// Estimated time to complete this step in seconds
  final int estimatedDuration;

  /// Warning messages for this step
  final List<String> warnings;

  /// Tools or ingredients needed for this step
  final List<String> tools;

  const GuideStep({
    required this.stepId,
    required this.title,
    required this.instruction,
    required this.successCriteria,
    this.referenceImageUrl,
    this.estimatedDuration = 0,
    this.warnings = const [],
    this.tools = const [],
  });

  /// Create a copy with updated values
  GuideStep copyWith({
    int? stepId,
    String? title,
    String? instruction,
    String? successCriteria,
    String? referenceImageUrl,
    int? estimatedDuration,
    List<String>? warnings,
    List<String>? tools,
  }) {
    return GuideStep(
      stepId: stepId ?? this.stepId,
      title: title ?? this.title,
      instruction: instruction ?? this.instruction,
      successCriteria: successCriteria ?? this.successCriteria,
      referenceImageUrl: referenceImageUrl ?? this.referenceImageUrl,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      warnings: warnings ?? this.warnings,
      tools: tools ?? this.tools,
    );
  }

  /// Serialize to JSON map
  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'title': title,
      'instruction': instruction,
      'successCriteria': successCriteria,
      'referenceImageUrl': referenceImageUrl,
      'estimatedDuration': estimatedDuration,
      'warnings': warnings,
      'tools': tools,
    };
  }

  /// Create from JSON map
  factory GuideStep.fromJson(Map<String, dynamic> json) {
    return GuideStep(
      stepId: json['stepId'] as int,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      successCriteria: json['successCriteria'] as String,
      referenceImageUrl: json['referenceImageUrl'] as String?,
      estimatedDuration: (json['estimatedDuration'] as int?) ?? 0,
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tools: (json['tools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuideStep &&
        other.stepId == stepId &&
        other.title == title &&
        other.instruction == instruction &&
        other.successCriteria == successCriteria &&
        other.referenceImageUrl == referenceImageUrl &&
        other.estimatedDuration == estimatedDuration &&
        _listEquals(other.warnings, warnings) &&
        _listEquals(other.tools, tools);
  }

  @override
  int get hashCode => Object.hash(
        stepId,
        title,
        instruction,
        successCriteria,
        referenceImageUrl,
        estimatedDuration,
        Object.hashAll(warnings),
        Object.hashAll(tools),
      );
}

/// A complete guide with steps for visual verification
///
/// Represents a parsed recipe, repair guide, or other task
/// that can be verified step-by-step using TrueStep's AI.
class Guide {
  /// Unique identifier for this guide
  final String guideId;

  /// Title of the guide
  final String title;

  /// Category of the guide (culinary, diy)
  final GuideCategory category;

  /// Source URL if ingested from a webpage
  final String? sourceUrl;

  /// List of steps in this guide
  final List<GuideStep> steps;

  /// Total estimated duration in seconds (0 if not specified)
  final int totalDuration;

  /// Difficulty level
  final GuideDifficulty difficulty;

  /// All tools/ingredients needed for this guide
  final List<String> tools;

  /// When this guide was created
  final DateTime createdAt;

  /// When this guide was last updated
  final DateTime updatedAt;

  const Guide({
    required this.guideId,
    required this.title,
    required this.category,
    this.sourceUrl,
    required this.steps,
    this.totalDuration = 0,
    this.difficulty = GuideDifficulty.easy,
    this.tools = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Number of steps in this guide
  int get stepCount => steps.length;

  /// Calculate total duration from step durations
  int get calculatedDuration =>
      steps.fold(0, (sum, step) => sum + step.estimatedDuration);

  /// Whether this guide was ingested from a URL
  bool get isFromUrl => sourceUrl != null;

  /// Create a copy with updated values
  Guide copyWith({
    String? guideId,
    String? title,
    GuideCategory? category,
    String? sourceUrl,
    List<GuideStep>? steps,
    int? totalDuration,
    GuideDifficulty? difficulty,
    List<String>? tools,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guide(
      guideId: guideId ?? this.guideId,
      title: title ?? this.title,
      category: category ?? this.category,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      steps: steps ?? this.steps,
      totalDuration: totalDuration ?? this.totalDuration,
      difficulty: difficulty ?? this.difficulty,
      tools: tools ?? this.tools,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialize to JSON map
  Map<String, dynamic> toJson() {
    return {
      'guideId': guideId,
      'title': title,
      'category': category.name,
      'sourceUrl': sourceUrl,
      'steps': steps.map((s) => s.toJson()).toList(),
      'totalDuration': totalDuration,
      'difficulty': difficulty.name,
      'tools': tools,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      guideId: json['guideId'] as String,
      title: json['title'] as String,
      category: GuideCategory.fromString(json['category'] as String?) ??
          GuideCategory.culinary,
      sourceUrl: json['sourceUrl'] as String?,
      steps: (json['steps'] as List<dynamic>)
          .map((s) => GuideStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      totalDuration: (json['totalDuration'] as int?) ?? 0,
      difficulty: GuideDifficulty.fromString(json['difficulty'] as String?) ??
          GuideDifficulty.easy,
      tools: (json['tools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guide &&
        other.guideId == guideId &&
        other.title == title &&
        other.category == category &&
        other.sourceUrl == sourceUrl &&
        other.totalDuration == totalDuration &&
        other.difficulty == difficulty &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _listEquals(other.tools, tools) &&
        _stepsEqual(other.steps, steps);
  }

  @override
  int get hashCode => Object.hash(
        guideId,
        title,
        category,
        sourceUrl,
        totalDuration,
        difficulty,
        createdAt,
        updatedAt,
        Object.hashAll(tools),
        Object.hashAll(steps),
      );
}

/// Helper to compare lists for equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Helper to compare step lists for equality
bool _stepsEqual(List<GuideStep> a, List<GuideStep> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
