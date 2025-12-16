import 'package:flutter_test/flutter_test.dart';

import 'package:truestep/core/models/guide.dart';

void main() {
  group('GuideStep', () {
    group('construction', () {
      test('creates GuideStep with required fields', () {
        final step = GuideStep(
          stepId: 1,
          title: 'Crack the eggs',
          instruction: 'Crack two eggs into a bowl',
          successCriteria: 'Two eggs cracked cleanly into bowl without shells',
        );

        expect(step.stepId, equals(1));
        expect(step.title, equals('Crack the eggs'));
        expect(step.instruction, equals('Crack two eggs into a bowl'));
        expect(
          step.successCriteria,
          equals('Two eggs cracked cleanly into bowl without shells'),
        );
      });

      test('creates GuideStep with all optional fields', () {
        final step = GuideStep(
          stepId: 1,
          title: 'Heat the pan',
          instruction: 'Place pan on medium heat',
          successCriteria: 'Pan is warm to the touch',
          referenceImageUrl: 'https://example.com/pan.jpg',
          estimatedDuration: 60,
          warnings: ['Pan handle may be hot'],
          tools: ['Non-stick pan', 'Spatula'],
        );

        expect(step.referenceImageUrl, equals('https://example.com/pan.jpg'));
        expect(step.estimatedDuration, equals(60));
        expect(step.warnings, equals(['Pan handle may be hot']));
        expect(step.tools, equals(['Non-stick pan', 'Spatula']));
      });

      test('has sensible defaults for optional fields', () {
        final step = GuideStep(
          stepId: 1,
          title: 'Test step',
          instruction: 'Do something',
          successCriteria: 'Something is done',
        );

        expect(step.referenceImageUrl, isNull);
        expect(step.estimatedDuration, equals(0));
        expect(step.warnings, isEmpty);
        expect(step.tools, isEmpty);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final original = GuideStep(
          stepId: 1,
          title: 'Original title',
          instruction: 'Original instruction',
          successCriteria: 'Original criteria',
          estimatedDuration: 30,
        );

        final copy = original.copyWith(
          title: 'Updated title',
          estimatedDuration: 60,
        );

        expect(copy.stepId, equals(1));
        expect(copy.title, equals('Updated title'));
        expect(copy.instruction, equals('Original instruction'));
        expect(copy.successCriteria, equals('Original criteria'));
        expect(copy.estimatedDuration, equals(60));
      });

      test('preserves original when no changes specified', () {
        final original = GuideStep(
          stepId: 1,
          title: 'Test',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
          warnings: ['Warning 1'],
        );

        final copy = original.copyWith();

        expect(copy.stepId, equals(original.stepId));
        expect(copy.title, equals(original.title));
        expect(copy.warnings, equals(original.warnings));
      });
    });

    group('equality', () {
      test('two GuideSteps with same values are equal', () {
        final step1 = GuideStep(
          stepId: 1,
          title: 'Test',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
        );

        final step2 = GuideStep(
          stepId: 1,
          title: 'Test',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
        );

        expect(step1, equals(step2));
        expect(step1.hashCode, equals(step2.hashCode));
      });

      test('two GuideSteps with different values are not equal', () {
        final step1 = GuideStep(
          stepId: 1,
          title: 'Test 1',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
        );

        final step2 = GuideStep(
          stepId: 2,
          title: 'Test 2',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
        );

        expect(step1, isNot(equals(step2)));
      });
    });

    group('serialization', () {
      test('toJson returns correct map', () {
        final step = GuideStep(
          stepId: 1,
          title: 'Crack eggs',
          instruction: 'Crack two eggs into bowl',
          successCriteria: 'Eggs in bowl without shells',
          referenceImageUrl: 'https://example.com/eggs.jpg',
          estimatedDuration: 30,
          warnings: ['Watch for shells'],
          tools: ['Bowl', 'Fork'],
        );

        final json = step.toJson();

        expect(json['stepId'], equals(1));
        expect(json['title'], equals('Crack eggs'));
        expect(json['instruction'], equals('Crack two eggs into bowl'));
        expect(json['successCriteria'], equals('Eggs in bowl without shells'));
        expect(json['referenceImageUrl'], equals('https://example.com/eggs.jpg'));
        expect(json['estimatedDuration'], equals(30));
        expect(json['warnings'], equals(['Watch for shells']));
        expect(json['tools'], equals(['Bowl', 'Fork']));
      });

      test('fromJson creates correct GuideStep', () {
        final json = {
          'stepId': 1,
          'title': 'Crack eggs',
          'instruction': 'Crack two eggs into bowl',
          'successCriteria': 'Eggs in bowl without shells',
          'referenceImageUrl': 'https://example.com/eggs.jpg',
          'estimatedDuration': 30,
          'warnings': ['Watch for shells'],
          'tools': ['Bowl', 'Fork'],
        };

        final step = GuideStep.fromJson(json);

        expect(step.stepId, equals(1));
        expect(step.title, equals('Crack eggs'));
        expect(step.instruction, equals('Crack two eggs into bowl'));
        expect(step.successCriteria, equals('Eggs in bowl without shells'));
        expect(step.referenceImageUrl, equals('https://example.com/eggs.jpg'));
        expect(step.estimatedDuration, equals(30));
        expect(step.warnings, equals(['Watch for shells']));
        expect(step.tools, equals(['Bowl', 'Fork']));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'stepId': 1,
          'title': 'Test',
          'instruction': 'Do something',
          'successCriteria': 'Something done',
        };

        final step = GuideStep.fromJson(json);

        expect(step.referenceImageUrl, isNull);
        expect(step.estimatedDuration, equals(0));
        expect(step.warnings, isEmpty);
        expect(step.tools, isEmpty);
      });

      test('roundtrip serialization preserves data', () {
        final original = GuideStep(
          stepId: 1,
          title: 'Test step',
          instruction: 'Test instruction',
          successCriteria: 'Test criteria',
          referenceImageUrl: 'https://example.com/test.jpg',
          estimatedDuration: 45,
          warnings: ['Warning 1', 'Warning 2'],
          tools: ['Tool 1', 'Tool 2'],
        );

        final json = original.toJson();
        final restored = GuideStep.fromJson(json);

        expect(restored, equals(original));
      });
    });
  });

  group('GuideDifficulty', () {
    test('has expected values', () {
      expect(GuideDifficulty.values, hasLength(3));
      expect(GuideDifficulty.values, contains(GuideDifficulty.easy));
      expect(GuideDifficulty.values, contains(GuideDifficulty.medium));
      expect(GuideDifficulty.values, contains(GuideDifficulty.hard));
    });

    test('fromString returns correct difficulty', () {
      expect(GuideDifficulty.fromString('easy'), equals(GuideDifficulty.easy));
      expect(GuideDifficulty.fromString('medium'), equals(GuideDifficulty.medium));
      expect(GuideDifficulty.fromString('hard'), equals(GuideDifficulty.hard));
    });

    test('fromString returns null for invalid value', () {
      expect(GuideDifficulty.fromString('invalid'), isNull);
      expect(GuideDifficulty.fromString(''), isNull);
    });

    test('fromString is case insensitive', () {
      expect(GuideDifficulty.fromString('EASY'), equals(GuideDifficulty.easy));
      expect(GuideDifficulty.fromString('Easy'), equals(GuideDifficulty.easy));
    });
  });

  group('GuideCategory', () {
    test('has expected values', () {
      expect(GuideCategory.values, hasLength(2));
      expect(GuideCategory.values, contains(GuideCategory.culinary));
      expect(GuideCategory.values, contains(GuideCategory.diy));
    });

    test('fromString returns correct category', () {
      expect(GuideCategory.fromString('culinary'), equals(GuideCategory.culinary));
      expect(GuideCategory.fromString('diy'), equals(GuideCategory.diy));
    });

    test('fromString returns null for invalid value', () {
      expect(GuideCategory.fromString('invalid'), isNull);
    });
  });

  group('Guide', () {
    late List<GuideStep> sampleSteps;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      sampleSteps = [
        GuideStep(
          stepId: 1,
          title: 'Step 1',
          instruction: 'First instruction',
          successCriteria: 'First criteria',
          estimatedDuration: 30,
        ),
        GuideStep(
          stepId: 2,
          title: 'Step 2',
          instruction: 'Second instruction',
          successCriteria: 'Second criteria',
          estimatedDuration: 45,
        ),
      ];
    });

    group('construction', () {
      test('creates Guide with required fields', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Perfect Scrambled Eggs',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.guideId, equals('guide-123'));
        expect(guide.title, equals('Perfect Scrambled Eggs'));
        expect(guide.category, equals(GuideCategory.culinary));
        expect(guide.steps, equals(sampleSteps));
        expect(guide.createdAt, equals(now));
        expect(guide.updatedAt, equals(now));
      });

      test('creates Guide with all optional fields', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Perfect Scrambled Eggs',
          category: GuideCategory.culinary,
          sourceUrl: 'https://recipe.com/eggs',
          steps: sampleSteps,
          totalDuration: 600,
          difficulty: GuideDifficulty.easy,
          tools: ['Pan', 'Spatula', 'Bowl'],
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.sourceUrl, equals('https://recipe.com/eggs'));
        expect(guide.totalDuration, equals(600));
        expect(guide.difficulty, equals(GuideDifficulty.easy));
        expect(guide.tools, equals(['Pan', 'Spatula', 'Bowl']));
      });

      test('has sensible defaults for optional fields', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test Guide',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.sourceUrl, isNull);
        expect(guide.totalDuration, equals(0));
        expect(guide.difficulty, equals(GuideDifficulty.easy));
        expect(guide.tools, isEmpty);
      });
    });

    group('computed properties', () {
      test('stepCount returns correct number of steps', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.stepCount, equals(2));
      });

      test('stepCount is 0 for empty steps list', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: const [],
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.stepCount, equals(0));
      });

      test('calculatedDuration sums step durations', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        // sampleSteps have 30 + 45 = 75 seconds
        expect(guide.calculatedDuration, equals(75));
      });

      test('isFromUrl returns true when sourceUrl is set', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          sourceUrl: 'https://example.com',
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.isFromUrl, isTrue);
      });

      test('isFromUrl returns false when sourceUrl is null', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide.isFromUrl, isFalse);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final original = Guide(
          guideId: 'guide-123',
          title: 'Original Title',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          difficulty: GuideDifficulty.easy,
          createdAt: now,
          updatedAt: now,
        );

        final copy = original.copyWith(
          title: 'Updated Title',
          difficulty: GuideDifficulty.hard,
        );

        expect(copy.guideId, equals('guide-123'));
        expect(copy.title, equals('Updated Title'));
        expect(copy.category, equals(GuideCategory.culinary));
        expect(copy.difficulty, equals(GuideDifficulty.hard));
      });

      test('preserves original when no changes specified', () {
        final original = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.diy,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        final copy = original.copyWith();

        expect(copy.guideId, equals(original.guideId));
        expect(copy.title, equals(original.title));
        expect(copy.category, equals(original.category));
      });
    });

    group('equality', () {
      test('two Guides with same values are equal', () {
        final guide1 = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        final guide2 = Guide(
          guideId: 'guide-123',
          title: 'Test',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide1, equals(guide2));
        expect(guide1.hashCode, equals(guide2.hashCode));
      });

      test('two Guides with different values are not equal', () {
        final guide1 = Guide(
          guideId: 'guide-123',
          title: 'Test 1',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        final guide2 = Guide(
          guideId: 'guide-456',
          title: 'Test 2',
          category: GuideCategory.culinary,
          steps: sampleSteps,
          createdAt: now,
          updatedAt: now,
        );

        expect(guide1, isNot(equals(guide2)));
      });
    });

    group('serialization', () {
      test('toJson returns correct map', () {
        final guide = Guide(
          guideId: 'guide-123',
          title: 'Perfect Scrambled Eggs',
          category: GuideCategory.culinary,
          sourceUrl: 'https://recipe.com/eggs',
          steps: sampleSteps,
          totalDuration: 600,
          difficulty: GuideDifficulty.easy,
          tools: ['Pan', 'Spatula'],
          createdAt: now,
          updatedAt: now,
        );

        final json = guide.toJson();

        expect(json['guideId'], equals('guide-123'));
        expect(json['title'], equals('Perfect Scrambled Eggs'));
        expect(json['category'], equals('culinary'));
        expect(json['sourceUrl'], equals('https://recipe.com/eggs'));
        expect(json['steps'], hasLength(2));
        expect(json['totalDuration'], equals(600));
        expect(json['difficulty'], equals('easy'));
        expect(json['tools'], equals(['Pan', 'Spatula']));
        expect(json['createdAt'], equals(now.toIso8601String()));
        expect(json['updatedAt'], equals(now.toIso8601String()));
      });

      test('fromJson creates correct Guide', () {
        final json = {
          'guideId': 'guide-123',
          'title': 'Perfect Scrambled Eggs',
          'category': 'culinary',
          'sourceUrl': 'https://recipe.com/eggs',
          'steps': [
            {
              'stepId': 1,
              'title': 'Step 1',
              'instruction': 'First instruction',
              'successCriteria': 'First criteria',
              'estimatedDuration': 30,
            },
          ],
          'totalDuration': 600,
          'difficulty': 'easy',
          'tools': ['Pan', 'Spatula'],
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final guide = Guide.fromJson(json);

        expect(guide.guideId, equals('guide-123'));
        expect(guide.title, equals('Perfect Scrambled Eggs'));
        expect(guide.category, equals(GuideCategory.culinary));
        expect(guide.sourceUrl, equals('https://recipe.com/eggs'));
        expect(guide.steps, hasLength(1));
        expect(guide.totalDuration, equals(600));
        expect(guide.difficulty, equals(GuideDifficulty.easy));
        expect(guide.tools, equals(['Pan', 'Spatula']));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'guideId': 'guide-123',
          'title': 'Test',
          'category': 'culinary',
          'steps': <Map<String, dynamic>>[],
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final guide = Guide.fromJson(json);

        expect(guide.sourceUrl, isNull);
        expect(guide.totalDuration, equals(0));
        expect(guide.difficulty, equals(GuideDifficulty.easy));
        expect(guide.tools, isEmpty);
      });

      test('roundtrip serialization preserves data', () {
        final original = Guide(
          guideId: 'guide-123',
          title: 'Test Guide',
          category: GuideCategory.diy,
          sourceUrl: 'https://example.com',
          steps: sampleSteps,
          totalDuration: 300,
          difficulty: GuideDifficulty.medium,
          tools: ['Tool 1', 'Tool 2'],
          createdAt: now,
          updatedAt: now,
        );

        final json = original.toJson();
        final restored = Guide.fromJson(json);

        expect(restored.guideId, equals(original.guideId));
        expect(restored.title, equals(original.title));
        expect(restored.category, equals(original.category));
        expect(restored.sourceUrl, equals(original.sourceUrl));
        expect(restored.totalDuration, equals(original.totalDuration));
        expect(restored.difficulty, equals(original.difficulty));
        expect(restored.tools, equals(original.tools));
        expect(restored.steps.length, equals(original.steps.length));
      });
    });
  });
}
