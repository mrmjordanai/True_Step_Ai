import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:truestep/services/ai_service.dart';

void main() {
  group('VerificationResponse', () {
    test('fromJson parses valid response', () {
      final json = {
        'verified': true,
        'confidence': 0.95,
        'issue': null,
        'safetyAlert': false,
        'suggestion': null,
      };

      final response = VerificationResponse.fromJson(json);

      expect(response.verified, true);
      expect(response.confidence, 0.95);
      expect(response.issue, isNull);
      expect(response.safetyAlert, false);
      expect(response.suggestion, isNull);
    });

    test('fromJson handles failure response', () {
      final json = {
        'verified': false,
        'confidence': 0.3,
        'issue': 'Step not complete - missing ingredient',
        'safetyAlert': false,
        'suggestion': 'Add the salt before continuing',
      };

      final response = VerificationResponse.fromJson(json);

      expect(response.verified, false);
      expect(response.confidence, 0.3);
      expect(response.issue, 'Step not complete - missing ingredient');
      expect(response.suggestion, 'Add the salt before continuing');
    });

    test('fromJson handles safety alert', () {
      final json = {
        'verified': false,
        'confidence': 0.8,
        'issue': 'Unsafe knife handling detected',
        'safetyAlert': true,
        'suggestion': 'Keep fingers curled while cutting',
      };

      final response = VerificationResponse.fromJson(json);

      expect(response.safetyAlert, true);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final response = VerificationResponse.fromJson(json);

      expect(response.verified, false);
      expect(response.confidence, 0.0);
      expect(response.safetyAlert, false);
    });

    test('error factory creates failed response', () {
      final response = VerificationResponse.error('Camera unavailable');

      expect(response.verified, false);
      expect(response.confidence, 0.0);
      expect(response.issue, 'Camera unavailable');
    });
  });

  group('AIService', () {
    test('can be instantiated', () {
      final service = AIService();
      expect(service, isNotNull);
      expect(service.isInitialized, false);
    });

    test('ensureInitialized throws if not initialized', () {
      final service = AIService();

      expect(() => service.ensureInitialized(), throwsA(isA<StateError>()));
    });

    // Note: Full integration tests require Firebase to be configured
    // These tests focus on response parsing and error handling
  });

  group('JSON parsing', () {
    test('valid verification JSON can be decoded', () {
      const jsonString = '''
{
  "verified": true,
  "confidence": 0.92,
  "issue": null,
  "safetyAlert": false,
  "suggestion": null
}
''';

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final response = VerificationResponse.fromJson(json);

      expect(response.verified, true);
      expect(response.confidence, 0.92);
    });

    test('handles JSON with extra fields gracefully', () {
      final json = {
        'verified': true,
        'confidence': 0.85,
        'extraField': 'should be ignored',
        'anotherExtra': 123,
      };

      final response = VerificationResponse.fromJson(json);

      expect(response.verified, true);
      expect(response.confidence, 0.85);
    });
  });
}
