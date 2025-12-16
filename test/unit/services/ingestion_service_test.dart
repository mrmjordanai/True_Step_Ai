import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:truestep/services/ingestion_service.dart';
import 'package:truestep/core/models/guide.dart';
import 'package:truestep/core/exceptions/app_exception.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<String> {}

void main() {
  group('IngestionService', () {
    late IngestionService service;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      service = IngestionService(dio: mockDio);
    });

    group('isUrl', () {
      test('returns true for valid http URL', () {
        expect(service.isUrl('http://example.com'), isTrue);
      });

      test('returns true for valid https URL', () {
        expect(service.isUrl('https://example.com'), isTrue);
      });

      test('returns true for URL with path', () {
        expect(service.isUrl('https://example.com/recipe/eggs'), isTrue);
      });

      test('returns true for URL with query params', () {
        expect(service.isUrl('https://example.com/recipe?id=123'), isTrue);
      });

      test('returns false for plain text', () {
        expect(service.isUrl('how to make scrambled eggs'), isFalse);
      });

      test('returns false for text with domain-like words', () {
        expect(service.isUrl('cook something.good'), isFalse);
      });

      test('returns false for empty string', () {
        expect(service.isUrl(''), isFalse);
      });

      test('returns false for URL without protocol', () {
        expect(service.isUrl('example.com'), isFalse);
      });

      test('returns true for www URLs with https', () {
        expect(service.isUrl('https://www.example.com'), isTrue);
      });
    });

    group('detectInputType', () {
      test('returns url for valid URL input', () {
        expect(
          service.detectInputType('https://example.com/recipe'),
          equals(InputType.url),
        );
      });

      test('returns text for plain text input', () {
        expect(
          service.detectInputType('How to make scrambled eggs'),
          equals(InputType.text),
        );
      });

      test('returns text for empty input', () {
        expect(service.detectInputType(''), equals(InputType.text));
      });
    });

    group('ingest', () {
      test('routes to ingestFromUrl for URL input', () async {
        // Setup mock for successful fetch
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn('''
          <html>
            <head><title>Test Recipe</title></head>
            <body>
              <h1>Scrambled Eggs</h1>
              <ol>
                <li>Crack eggs</li>
                <li>Whisk</li>
                <li>Cook</li>
              </ol>
            </body>
          </html>
        ''');

        when(() => mockDio.get<String>(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        // Note: This will fail without AI service integration
        // For now we test that it attempts to fetch
        try {
          await service.ingest('https://example.com/recipe');
        } catch (e) {
          // Expected - AI parsing not implemented yet
          expect(e, isA<IngestionException>());
        }

        verify(() => mockDio.get<String>(
              'https://example.com/recipe',
              options: any(named: 'options'),
            )).called(1);
      });

      test('returns text-based guide for text input', () async {
        // Text ingestion creates a basic guide from the description
        final guide = await service.ingest('Make scrambled eggs');

        expect(guide, isA<Guide>());
        expect(guide.title, contains('scrambled eggs'));
        expect(guide.category, equals(GuideCategory.culinary));
      });
    });

    group('ingestFromUrl', () {
      test('throws IngestionException for invalid URL', () async {
        expect(
          () => service.ingestFromUrl('not-a-url'),
          throwsA(isA<IngestionException>().having(
            (e) => e.code,
            'code',
            equals('invalid_url'),
          )),
        );
      });

      test('fetches HTML from URL', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn('<html><body>Test</body></html>');

        when(() => mockDio.get<String>(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        try {
          await service.ingestFromUrl('https://example.com/recipe');
        } catch (e) {
          // Expected - AI parsing not fully implemented
        }

        verify(() => mockDio.get<String>(
              'https://example.com/recipe',
              options: any(named: 'options'),
            )).called(1);
      });

      test('throws IngestionException on network error', () async {
        when(() => mockDio.get<String>(
              any(),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ));

        expect(
          () => service.ingestFromUrl('https://example.com/recipe'),
          throwsA(isA<IngestionException>().having(
            (e) => e.code,
            'code',
            equals('fetch_failed'),
          )),
        );
      });

      test('throws IngestionException on 404 response', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(404);

        when(() => mockDio.get<String>(
              any(),
              options: any(named: 'options'),
            )).thenAnswer((_) async => mockResponse);

        expect(
          () => service.ingestFromUrl('https://example.com/recipe'),
          throwsA(isA<IngestionException>().having(
            (e) => e.code,
            'code',
            equals('fetch_failed'),
          )),
        );
      });
    });

    group('ingestFromText', () {
      test('creates guide from text description', () async {
        final guide = await service.ingestFromText('How to make scrambled eggs');

        expect(guide, isA<Guide>());
        expect(guide.guideId, isNotEmpty);
        expect(guide.title, isNotEmpty);
        expect(guide.category, equals(GuideCategory.culinary));
      });

      test('detects culinary category from food keywords', () async {
        final guide = await service.ingestFromText('cook pasta with sauce');

        expect(guide.category, equals(GuideCategory.culinary));
      });

      test('detects diy category from repair keywords', () async {
        final guide = await service.ingestFromText('fix broken screen');

        expect(guide.category, equals(GuideCategory.diy));
      });

      test('creates step from description', () async {
        final guide = await service.ingestFromText('Make scrambled eggs');

        expect(guide.steps, isNotEmpty);
        expect(guide.steps.first.instruction, isNotEmpty);
      });

      test('throws for empty input', () async {
        expect(
          () => service.ingestFromText(''),
          throwsA(isA<IngestionException>().having(
            (e) => e.code,
            'code',
            equals('no_content'),
          )),
        );
      });

      test('throws for whitespace-only input', () async {
        expect(
          () => service.ingestFromText('   '),
          throwsA(isA<IngestionException>().having(
            (e) => e.code,
            'code',
            equals('no_content'),
          )),
        );
      });
    });

    group('lifecycle', () {
      test('initializes without error', () async {
        // Create a real service for lifecycle tests (no mock)
        final realService = IngestionService();
        await expectLater(realService.initialize(), completes);
        expect(realService.isInitialized, isTrue);
        await realService.dispose();
      });

      test('disposes without error', () async {
        // Create a real service for lifecycle tests (no mock)
        final realService = IngestionService();
        await realService.initialize();
        await expectLater(realService.dispose(), completes);
        expect(realService.isInitialized, isFalse);
      });
    });
  });
}
