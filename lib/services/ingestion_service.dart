import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions/app_exception.dart';
import '../core/models/guide.dart';
import 'ai_service.dart';
import 'base_service.dart';
import 'guide_cache_service.dart';

/// Input type detected from user input
enum InputType {
  /// Input is a URL
  url,

  /// Input is plain text description
  text,
}

/// Service for ingesting guides from URLs and text descriptions
///
/// Handles:
/// - URL detection and validation
/// - Web scraping to fetch HTML content
/// - Text parsing and guide generation
/// - (Future) AI-powered content extraction via Gemini
class IngestionService extends BaseService {
  final Dio _dio;

  /// Regular expression for URL detection
  static final _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );

  /// Keywords that indicate culinary content
  static const _culinaryKeywords = [
    'cook',
    'recipe',
    'bake',
    'fry',
    'boil',
    'grill',
    'food',
    'meal',
    'dish',
    'eggs',
    'pasta',
    'sauce',
    'chicken',
    'beef',
    'vegetable',
    'ingredient',
    'kitchen',
    'oven',
    'stove',
  ];

  /// Keywords that indicate DIY content
  static const _diyKeywords = [
    'fix',
    'repair',
    'replace',
    'install',
    'build',
    'assemble',
    'broken',
    'screen',
    'battery',
    'tool',
    'screw',
    'wire',
    'plumbing',
    'electrical',
    'furniture',
  ];

  /// Create an IngestionService with optional Dio instance
  IngestionService({Dio? dio}) : _dio = dio ?? Dio();

  /// AI service for intelligent parsing (optional)
  AIService? _aiService;

  /// Cache service for storing parsed guides (optional)
  GuideCacheService? _cacheService;

  /// Set the AI service for intelligent parsing
  void setAiService(AIService? aiService) {
    _aiService = aiService;
  }

  /// Set the cache service for storing parsed guides
  void setCacheService(GuideCacheService? cacheService) {
    _cacheService = cacheService;
  }

  @override
  Future<void> onInitialize() async {
    // Configure Dio defaults
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  Future<void> onDispose() async {
    _dio.close();
  }

  /// Check if input string is a valid URL
  bool isUrl(String input) {
    if (input.isEmpty) return false;
    return _urlRegex.hasMatch(input.trim());
  }

  /// Detect the type of input (URL or text)
  InputType detectInputType(String input) {
    if (isUrl(input)) {
      return InputType.url;
    }
    return InputType.text;
  }

  /// Ingest content from any input type
  ///
  /// Automatically detects if input is a URL or text description
  /// and routes to the appropriate ingestion method.
  Future<Guide> ingest(String input) async {
    final inputType = detectInputType(input);

    switch (inputType) {
      case InputType.url:
        return ingestFromUrl(input);
      case InputType.text:
        return ingestFromText(input);
    }
  }

  /// Ingest a guide from a URL
  ///
  /// Fetches HTML content from the URL, then parses it into a Guide.
  /// Uses cache when available, AI parsing with fallback to regex.
  Future<Guide> ingestFromUrl(String url) async {
    // Validate URL
    if (!isUrl(url)) {
      throw IngestionException.invalidUrl(url);
    }

    // Check cache first
    if (_cacheService != null && _cacheService!.isInitialized) {
      try {
        final cached = await _cacheService!.getCachedGuide(url);
        if (cached != null) {
          return cached;
        }
      } catch (e) {
        // Cache lookup failed, continue with fetch
      }
    }

    // Fetch HTML content
    final html = await _fetchHtml(url);
    Guide guide;

    // Use AI parsing if available
    if (_aiService != null && _aiService!.isInitialized) {
      try {
        guide = await _aiService!.parseHtmlToGuide(html, url);
      } catch (e) {
        // Fall back to basic parsing on AI error
        guide = _parseHtmlToGuideBasic(html, url);
      }
    } else {
      // Basic parsing (fallback)
      guide = _parseHtmlToGuideBasic(html, url);
    }

    // Cache the result
    if (_cacheService != null && _cacheService!.isInitialized) {
      try {
        await _cacheService!.cacheGuide(guide, url);
      } catch (e) {
        // Cache save failed, continue without caching
      }
    }

    return guide;
  }

  /// Ingest a guide from a text description
  ///
  /// Creates a structured guide from natural language input.
  /// Uses AI parsing when available, falls back to basic parsing.
  Future<Guide> ingestFromText(String description) async {
    final trimmed = description.trim();

    if (trimmed.isEmpty) {
      throw IngestionException.noContent();
    }

    // Use AI parsing if available
    if (_aiService != null && _aiService!.isInitialized) {
      try {
        return await _aiService!.parseTextToGuide(trimmed);
      } catch (e) {
        // Fall back to basic parsing on AI error
        return _parseTextToGuideBasic(trimmed);
      }
    }

    // Basic parsing (fallback)
    return _parseTextToGuideBasic(trimmed);
  }

  /// Basic text-to-guide parsing (fallback when AI unavailable)
  Guide _parseTextToGuideBasic(String description) {
    // Detect category from keywords
    final category = _detectCategory(description);

    final now = DateTime.now();
    final guideId = 'guide_${now.millisecondsSinceEpoch}';

    return Guide(
      guideId: guideId,
      title: _generateTitle(description),
      category: category,
      steps: [
        GuideStep(
          stepId: 1,
          title: 'Start',
          instruction: description,
          successCriteria: 'Task completed as described',
        ),
      ],
      difficulty: GuideDifficulty.easy,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Fetch HTML content from a URL
  Future<String> _fetchHtml(String url) async {
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (compatible; TrueStep/1.0; +https://truestep.app)',
            'Accept': 'text/html,application/xhtml+xml',
          },
          responseType: ResponseType.plain,
        ),
      );

      if (response.statusCode != 200) {
        throw IngestionException.fetchFailed(
          url,
          'Server returned status ${response.statusCode}',
        );
      }

      final data = response.data;
      if (data == null || data.isEmpty) {
        throw IngestionException.noContent(url);
      }

      return data;
    } on DioException catch (e) {
      throw IngestionException.fetchFailed(url, _mapDioError(e));
    }
  }

  /// Basic HTML-to-guide parsing (fallback when AI unavailable)
  ///
  /// Extracts title and list items using regex. More limited than AI parsing.
  Guide _parseHtmlToGuideBasic(String html, String url) {
    // Basic title extraction
    final titleMatch = RegExp(r'<title>([^<]+)</title>').firstMatch(html);
    final h1Match = RegExp(r'<h1[^>]*>([^<]+)</h1>').firstMatch(html);
    final title =
        h1Match?.group(1)?.trim() ??
        titleMatch?.group(1)?.trim() ??
        'Untitled Guide';

    // Extract list items as potential steps
    final listItemRegex = RegExp(r'<li[^>]*>([^<]+)</li>');
    final listItems = listItemRegex
        .allMatches(html)
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .take(20) // Limit to 20 steps
        .toList();

    // If no list items, throw parsing error
    if (listItems.isEmpty) {
      throw IngestionException.parsingFailed(
        'Could not find recipe steps on this page. Try a different URL.',
      );
    }

    final now = DateTime.now();
    final guideId = 'guide_${now.millisecondsSinceEpoch}';

    final steps = listItems.asMap().entries.map((entry) {
      return GuideStep(
        stepId: entry.key + 1,
        title: 'Step ${entry.key + 1}',
        instruction: entry.value,
        successCriteria: 'Step ${entry.key + 1} completed',
      );
    }).toList();

    return Guide(
      guideId: guideId,
      title: title,
      category: _detectCategoryFromHtml(html),
      sourceUrl: url,
      steps: steps,
      difficulty: GuideDifficulty.easy,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Detect category from text keywords
  GuideCategory _detectCategory(String text) {
    final lower = text.toLowerCase();

    int culinaryScore = 0;
    int diyScore = 0;

    for (final keyword in _culinaryKeywords) {
      if (lower.contains(keyword)) culinaryScore++;
    }

    for (final keyword in _diyKeywords) {
      if (lower.contains(keyword)) diyScore++;
    }

    return diyScore > culinaryScore
        ? GuideCategory.diy
        : GuideCategory.culinary;
  }

  /// Detect category from HTML content
  GuideCategory _detectCategoryFromHtml(String html) {
    return _detectCategory(html);
  }

  /// Generate a title from description
  String _generateTitle(String description) {
    // Capitalize first letter and take first 50 chars
    final trimmed = description.trim();
    if (trimmed.isEmpty) return 'New Task';

    final title = trimmed.length > 50
        ? '${trimmed.substring(0, 47)}...'
        : trimmed;

    return title[0].toUpperCase() + title.substring(1);
  }

  /// Map Dio errors to user-friendly messages
  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect to the server. Please check your internet.';
      case DioExceptionType.badResponse:
        return 'Server returned an error (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}

/// Provider for IngestionService
/// Can be overridden in tests with a mock
final ingestionServiceProvider = Provider<IngestionService>((ref) {
  final service = IngestionService();
  ref.onDispose(() => service.dispose());
  return service;
});
