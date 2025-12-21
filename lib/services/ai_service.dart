import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/guide.dart';
import '../core/utils/performance.dart';
import 'base_service.dart';

/// Response from AI verification of a step
class VerificationResponse {
  final bool verified;
  final double confidence;
  final String? issue;
  final bool safetyAlert;
  final String? suggestion;

  const VerificationResponse({
    required this.verified,
    required this.confidence,
    this.issue,
    this.safetyAlert = false,
    this.suggestion,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      verified: json['verified'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      issue: json['issue'] as String?,
      safetyAlert: json['safetyAlert'] as bool? ?? false,
      suggestion: json['suggestion'] as String?,
    );
  }

  /// Create a failed response for error cases
  factory VerificationResponse.error(String message) {
    return VerificationResponse(
      verified: false,
      confidence: 0.0,
      issue: message,
    );
  }

  /// Create a rate limited response
  factory VerificationResponse.rateLimited() {
    return const VerificationResponse(
      verified: false,
      confidence: 0.0,
      issue: 'Too many verification requests. Please wait a moment.',
    );
  }
}

/// AI Service for Gemini-powered verification and parsing
///
/// Provides:
/// - Step verification via image analysis
/// - HTML to Guide parsing
/// - Text description to Guide parsing
class AIService extends BaseService {
  GenerativeModel? _model;

  /// Rate limiter: max 30 verification calls per minute
  final RateLimiter _verificationLimiter = RateLimiter(
    maxCalls: 30,
    window: const Duration(minutes: 1),
  );

  /// The Gemini model to use for generation
  static const String _modelName = 'gemini-2.0-flash';

  @override
  Future<void> onInitialize() async {
    _model = FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1, // Low temperature for consistent output
      ),
      safetySettings: [
        // Allow content about tools, cooking, etc.
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.high,
          null,
        ),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high, null),
      ],
    );
  }

  @override
  Future<void> onDispose() async {
    _model = null;
  }

  /// Verify if a step has been completed using image analysis
  ///
  /// Returns [VerificationResponse] with verification result and confidence.
  /// Rate limited to 30 calls per minute.
  Future<VerificationResponse> verifyStep({
    required Uint8List imageBytes,
    required String stepTitle,
    required String successCriteria,
    String? referenceDescription,
  }) async {
    ensureInitialized();

    // Check rate limit
    if (!_verificationLimiter.tryCall()) {
      return VerificationResponse.rateLimited();
    }

    final prompt = _buildVerificationPrompt(
      stepTitle: stepTitle,
      successCriteria: successCriteria,
      referenceDescription: referenceDescription,
    );

    try {
      final response = await _model!.generateContent([
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ]),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        return VerificationResponse.error('Empty response from AI');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      return VerificationResponse.fromJson(json);
    } catch (e) {
      return VerificationResponse.error('Verification failed: $e');
    }
  }

  /// Parse HTML content into a structured Guide
  Future<Guide> parseHtmlToGuide(String html, String url) async {
    ensureInitialized();

    final prompt = _buildHtmlParsingPrompt(html, url);

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      return _parseGuideFromJson(json, url);
    } catch (e) {
      throw Exception('Failed to parse HTML: $e');
    }
  }

  /// Parse natural language description into a Guide
  Future<Guide> parseTextToGuide(String description) async {
    ensureInitialized();

    final prompt = _buildTextParsingPrompt(description);

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from AI');
      }

      final json = jsonDecode(text) as Map<String, dynamic>;
      return _parseGuideFromJson(json, null);
    } catch (e) {
      throw Exception('Failed to parse description: $e');
    }
  }

  // ==================== PRIVATE METHODS ====================

  String _buildVerificationPrompt({
    required String stepTitle,
    required String successCriteria,
    String? referenceDescription,
  }) {
    return '''
You are TrueStep's visual verification agent for physical tasks.

Current Step: $stepTitle
Success Criteria: $successCriteria
${referenceDescription != null ? 'Reference: $referenceDescription' : ''}

Analyze the provided image and determine if the step is completed.

Respond in JSON format only:
{
  "verified": boolean,
  "confidence": number (0.0-1.0),
  "issue": string or null,
  "safetyAlert": boolean,
  "suggestion": string or null
}

Rules:
- verified=true ONLY if success criteria is clearly met in the image
- Be strict: if uncertain, set verified=false
- Detect safety issues (sharp objects near fingers, hot surfaces, spills)
- Provide helpful suggestions if not verified
''';
  }

  String _buildHtmlParsingPrompt(String html, String url) {
    // Truncate HTML if too long (Gemini has token limits)
    final truncatedHtml = html.length > 50000 ? html.substring(0, 50000) : html;

    return '''
You are a guide extraction agent for TrueStep.

Parse the following HTML from URL: $url
Extract a step-by-step guide suitable for hands-on tasks.

HTML Content:
$truncatedHtml

Respond in JSON format only:
{
  "title": "string - the guide title",
  "category": "culinary" | "diy",
  "difficulty": "easy" | "medium" | "hard",
  "steps": [
    {
      "title": "string - short step title",
      "instruction": "string - detailed instruction",
      "successCriteria": "string - how to know step is complete",
      "estimatedDuration": number (seconds),
      "tools": ["list", "of", "tools"],
      "warnings": ["list", "of", "safety", "warnings"] or []
    }
  ],
  "totalDuration": number (total seconds estimate)
}

Rules:
- Extract clear, actionable steps
- Each step should be verifiable by looking at the result
- Include specific success criteria for visual verification
- Estimate realistic durations
- Tag required tools per step
''';
  }

  String _buildTextParsingPrompt(String description) {
    return '''
You are a guide creation agent for TrueStep.

Create a step-by-step guide from this description:
$description

Respond in JSON format only:
{
  "title": "string - the guide title",
  "category": "culinary" | "diy",
  "difficulty": "easy" | "medium" | "hard",
  "steps": [
    {
      "title": "string - short step title",
      "instruction": "string - detailed instruction",
      "successCriteria": "string - how to know step is complete",
      "estimatedDuration": number (seconds),
      "tools": ["list", "of", "tools"],
      "warnings": ["list", "of", "safety", "warnings"] or []
    }
  ],
  "totalDuration": number (total seconds estimate)
}

Rules:
- Break down into clear, actionable steps
- Each step should be verifiable visually
- Include specific success criteria
- Estimate realistic durations
''';
  }

  Guide _parseGuideFromJson(Map<String, dynamic> json, String? sourceUrl) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];

    final steps = stepsJson.asMap().entries.map((entry) {
      final stepJson = entry.value as Map<String, dynamic>;
      return GuideStep(
        stepId: entry.key + 1,
        title: stepJson['title'] as String? ?? 'Step ${entry.key + 1}',
        instruction: stepJson['instruction'] as String? ?? '',
        successCriteria: stepJson['successCriteria'] as String? ?? '',
        estimatedDuration: stepJson['estimatedDuration'] as int? ?? 60,
        tools:
            (stepJson['tools'] as List<dynamic>?)
                ?.map((t) => t.toString())
                .toList() ??
            [],
        warnings:
            (stepJson['warnings'] as List<dynamic>?)
                ?.map((w) => w.toString())
                .toList() ??
            [],
      );
    }).toList();

    return Guide(
      guideId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled Guide',
      category: _parseCategory(json['category'] as String?),
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      steps: steps,
      totalDuration: json['totalDuration'] as int? ?? 600,
      sourceUrl: sourceUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  GuideCategory _parseCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'culinary':
        return GuideCategory.culinary;
      case 'diy':
        return GuideCategory.diy;
      default:
        return GuideCategory.diy;
    }
  }

  GuideDifficulty _parseDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return GuideDifficulty.easy;
      case 'medium':
        return GuideDifficulty.medium;
      case 'hard':
        return GuideDifficulty.hard;
      default:
        return GuideDifficulty.medium;
    }
  }
}

/// Provider for AIService
final aiServiceProvider = Provider<AIService>((ref) {
  final service = AIService();
  ref.onDispose(() => service.dispose());
  return service;
});
