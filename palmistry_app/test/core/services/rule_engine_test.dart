import 'package:flutter_test/flutter_test.dart';
import 'package:palmistry_app/core/services/rule_engine.dart';

void main() {
  late RuleEngine engine;

  setUp(() {
    engine = RuleEngine();
  });

  group('loadRulesFromJsonList', () {
    test('loads rules correctly from JSON list', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'test_01',
          'conditions': {'lineType': 'heart', 'length': 'long'},
          'category': 'love',
          'trait': 'Тест',
          'confidence': 0.8,
          'description': 'Описание теста',
        },
        {
          'id': 'test_02',
          'conditions': {'palmShape': 'square'},
          'category': 'personality',
          'trait': 'Тест 2',
          'confidence': 0.75,
          'description': 'Описание теста 2',
        },
      ]);

      expect(engine.rules.length, 2);
      expect(engine.rules[0].id, 'test_01');
      expect(engine.rules[0].conditions['lineType'], 'heart');
      expect(engine.rules[1].category, 'personality');
    });
  });

  group('evaluate line rules', () {
    test('returns matching traits for heart line', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'heart_long_curved',
          'conditions': {
            'lineType': 'heart',
            'length': 'long',
            'curvature': 'curved',
          },
          'category': 'love',
          'trait': 'Идеализм в любви',
          'confidence': 0.85,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [
          const LineData(
            lineType: 'heart',
            length: 'long',
            depth: 'deep',
            curvature: 'curved',
            startPoint: 'edge',
            endPoint: 'jupiter',
          ),
        ],
      );

      expect(results.length, 1);
      expect(results[0].ruleId, 'heart_long_curved');
      expect(results[0].trait, 'Идеализм в любви');
      expect(results[0].lineType, 'heart');
      expect(results[0].confidence, 0.85);
    });

    test('returns empty list for non-matching conditions', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'heart_short',
          'conditions': {
            'lineType': 'heart',
            'length': 'short',
            'curvature': 'straight',
          },
          'category': 'love',
          'trait': 'Сдержанность',
          'confidence': 0.80,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [
          const LineData(
            lineType: 'heart',
            length: 'long',
            depth: 'deep',
            curvature: 'curved',
            startPoint: 'edge',
            endPoint: 'jupiter',
          ),
        ],
      );

      expect(results, isEmpty);
    });

    test('returns empty when no lines provided', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'heart_01',
          'conditions': {'lineType': 'heart', 'length': 'long'},
          'category': 'love',
          'trait': 'Тест',
          'confidence': 0.8,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [],
      );

      expect(results, isEmpty);
    });
  });

  group('evaluate palm shape rules', () {
    test('matches palm shape correctly', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'palm_square',
          'conditions': {'palmShape': 'square'},
          'category': 'personality',
          'trait': 'Стихия Земли',
          'confidence': 0.82,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: 'square',
        fingerProportions: null,
        lines: [],
      );

      expect(results.length, 1);
      expect(results[0].trait, 'Стихия Земли');
      expect(results[0].lineType, isNull);
    });

    test('does not match wrong palm shape', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'palm_square',
          'conditions': {'palmShape': 'square'},
          'category': 'personality',
          'trait': 'Стихия Земли',
          'confidence': 0.82,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: 'conic',
        fingerProportions: null,
        lines: [],
      );

      expect(results, isEmpty);
    });

    test('matches palm shape with finger length condition', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'palm_square_short',
          'conditions': {'palmShape': 'square', 'fingerLength': 'short'},
          'category': 'personality',
          'trait': 'Практик-реалист',
          'confidence': 0.79,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: 'square',
        fingerProportions: {'index': 0.4, 'middle': 0.45, 'ring': 0.38, 'pinky': 0.35},
        lines: [],
      );

      expect(results.length, 1);
      expect(results[0].trait, 'Практик-реалист');
    });
  });

  group('evaluate finger rules', () {
    test('matches long finger proportion', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'finger_index_long',
          'conditions': {'finger': 'index', 'proportion': 'long'},
          'category': 'personality',
          'trait': 'Амбициозность',
          'confidence': 0.78,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: {'index': 0.6, 'ring': 0.5},
        lines: [],
      );

      expect(results.length, 1);
      expect(results[0].trait, 'Амбициозность');
    });

    test('matches equal finger proportion', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'finger_equal',
          'conditions': {'finger': 'index', 'proportion': 'equal'},
          'category': 'personality',
          'trait': 'Сбалансированность',
          'confidence': 0.74,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: {'index': 0.52, 'ring': 0.51},
        lines: [],
      );

      expect(results.length, 1);
      expect(results[0].trait, 'Сбалансированность');
    });

    test('does not match finger when proportions missing', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'finger_long',
          'conditions': {'finger': 'index', 'proportion': 'long'},
          'category': 'personality',
          'trait': 'Амбициозность',
          'confidence': 0.78,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [],
      );

      expect(results, isEmpty);
    });
  });

  group('multiple rules firing', () {
    test('multiple rules can fire for the same line', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'heart_long',
          'conditions': {'lineType': 'heart', 'length': 'long'},
          'category': 'love',
          'trait': 'Трейт 1',
          'confidence': 0.80,
          'description': 'Описание 1',
        },
        {
          'id': 'heart_deep',
          'conditions': {'lineType': 'heart', 'depth': 'deep'},
          'category': 'love',
          'trait': 'Трейт 2',
          'confidence': 0.75,
          'description': 'Описание 2',
        },
        {
          'id': 'head_long',
          'conditions': {'lineType': 'head', 'length': 'long'},
          'category': 'personality',
          'trait': 'Трейт 3',
          'confidence': 0.85,
          'description': 'Описание 3',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [
          const LineData(
            lineType: 'heart',
            length: 'long',
            depth: 'deep',
            curvature: 'curved',
            startPoint: 'edge',
            endPoint: 'jupiter',
          ),
        ],
      );

      expect(results.length, 2);
      expect(results.map((r) => r.ruleId).toList(), ['heart_long', 'heart_deep']);
    });

    test('rules fire for multiple different lines', () {
      engine.loadRulesFromJsonList([
        {
          'id': 'heart_rule',
          'conditions': {'lineType': 'heart', 'length': 'long'},
          'category': 'love',
          'trait': 'Трейт сердца',
          'confidence': 0.80,
          'description': 'Описание',
        },
        {
          'id': 'head_rule',
          'conditions': {'lineType': 'head', 'depth': 'deep'},
          'category': 'personality',
          'trait': 'Трейт головы',
          'confidence': 0.82,
          'description': 'Описание',
        },
      ]);

      final results = engine.evaluate(
        palmShape: null,
        fingerProportions: null,
        lines: [
          const LineData(
            lineType: 'heart',
            length: 'long',
            depth: 'medium',
            curvature: 'curved',
            startPoint: 'edge',
            endPoint: 'jupiter',
          ),
          const LineData(
            lineType: 'head',
            length: 'medium',
            depth: 'deep',
            curvature: 'straight',
            startPoint: 'connected_to_life',
            endPoint: 'luna',
          ),
        ],
      );

      expect(results.length, 2);
      expect(results[0].lineType, 'heart');
      expect(results[1].lineType, 'head');
    });
  });
}
