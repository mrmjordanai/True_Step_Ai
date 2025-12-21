import 'package:freezed_annotation/freezed_annotation.dart';

part 'guide.freezed.dart';
part 'guide.g.dart';

/// Guide difficulty levels
@JsonEnum(alwaysCreate: true)
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
@JsonEnum(alwaysCreate: true)
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
@freezed
class GuideStep with _$GuideStep {
  const factory GuideStep({
    /// Unique identifier for this step within the guide
    required int stepId,

    /// Brief title of the step
    required String title,

    /// Detailed instruction text
    required String instruction,

    /// Criteria for visual verification (what should be visible when complete)
    required String successCriteria,

    /// Optional reference image URL for comparison
    String? referenceImageUrl,

    /// Estimated time to complete this step in seconds
    @Default(0) int estimatedDuration,

    /// Warning messages for this step
    @Default([]) List<String> warnings,

    /// Tools or ingredients needed for this step
    @Default([]) List<String> tools,
  }) = _GuideStep;

  factory GuideStep.fromJson(Map<String, dynamic> json) =>
      _$GuideStepFromJson(json);
}

/// A complete guide with steps for visual verification
///
/// Represents a parsed recipe, repair guide, or other task
/// that can be verified step-by-step using TrueStep's AI.
@freezed
class Guide with _$Guide {
  const Guide._(); // Enable computed properties

  const factory Guide({
    /// Unique identifier for this guide
    required String guideId,

    /// Title of the guide
    required String title,

    /// Category of the guide (culinary, diy)
    required GuideCategory category,

    /// Source URL if ingested from a webpage
    String? sourceUrl,

    /// List of steps in this guide
    required List<GuideStep> steps,

    /// Total estimated duration in seconds (0 if not specified)
    @Default(0) int totalDuration,

    /// Difficulty level
    @Default(GuideDifficulty.easy) GuideDifficulty difficulty,

    /// All tools/ingredients needed for this guide
    @Default([]) List<String> tools,

    /// When this guide was created
    required DateTime createdAt,

    /// When this guide was last updated
    required DateTime updatedAt,
  }) = _Guide;

  /// Number of steps in this guide
  int get stepCount => steps.length;

  /// Calculate total duration from step durations
  int get calculatedDuration =>
      steps.fold(0, (sum, step) => sum + step.estimatedDuration);

  /// Whether this guide was ingested from a URL
  bool get isFromUrl => sourceUrl != null;

  factory Guide.fromJson(Map<String, dynamic> json) => _$GuideFromJson(json);
}
