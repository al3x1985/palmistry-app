import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:palmistry_app/core/models/interpretation.dart';

void main() {
  const validJson = '''
{
  "overview": "You have a balanced hand.",
  "personality": "Creative and intuitive.",
  "relationships": "Deep connections.",
  "career": "Leadership potential.",
  "health": "Strong constitution.",
  "disclaimer": "For entertainment only."
}
''';

  group('PalmInterpretation.fromJsonString', () {
    test('parses valid JSON correctly', () {
      final interp = PalmInterpretation.fromJsonString(validJson);

      expect(interp.overview, 'You have a balanced hand.');
      expect(interp.personality, 'Creative and intuitive.');
      expect(interp.relationships, 'Deep connections.');
      expect(interp.career, 'Leadership potential.');
      expect(interp.health, 'Strong constitution.');
      expect(interp.disclaimer, 'For entertainment only.');
    });

    test('parses valid JSON without optional disclaimer', () {
      final noDisclaimer = jsonEncode({
        'overview': 'Overview',
        'personality': 'Personality',
        'relationships': 'Relationships',
        'career': 'Career',
        'health': 'Health',
      });

      final interp = PalmInterpretation.fromJsonString(noDisclaimer);
      expect(interp.disclaimer, isNull);
    });

    test('throws FormatException when overview is missing', () {
      final missingOverview = jsonEncode({
        'personality': 'Personality',
        'relationships': 'Relationships',
        'career': 'Career',
        'health': 'Health',
      });

      expect(
        () => PalmInterpretation.fromJsonString(missingOverview),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when personality is missing', () {
      final missing = jsonEncode({
        'overview': 'Overview',
        'relationships': 'Relationships',
        'career': 'Career',
        'health': 'Health',
      });

      expect(
        () => PalmInterpretation.fromJsonString(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when relationships is missing', () {
      final missing = jsonEncode({
        'overview': 'Overview',
        'personality': 'Personality',
        'career': 'Career',
        'health': 'Health',
      });

      expect(
        () => PalmInterpretation.fromJsonString(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when career is missing', () {
      final missing = jsonEncode({
        'overview': 'Overview',
        'personality': 'Personality',
        'relationships': 'Relationships',
        'health': 'Health',
      });

      expect(
        () => PalmInterpretation.fromJsonString(missing),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when health is missing', () {
      final missing = jsonEncode({
        'overview': 'Overview',
        'personality': 'Personality',
        'relationships': 'Relationships',
        'career': 'Career',
      });

      expect(
        () => PalmInterpretation.fromJsonString(missing),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PalmInterpretation serialization roundtrip', () {
    test('toJsonString and fromJsonString produce equal objects', () {
      final original = PalmInterpretation.fromJsonString(validJson);
      final serialized = original.toJsonString();
      final restored = PalmInterpretation.fromJsonString(serialized);

      expect(restored.overview, original.overview);
      expect(restored.personality, original.personality);
      expect(restored.relationships, original.relationships);
      expect(restored.career, original.career);
      expect(restored.health, original.health);
      expect(restored.disclaimer, original.disclaimer);
    });

    test('toJsonString produces valid JSON with all required fields', () {
      final interp = PalmInterpretation.fromJsonString(validJson);
      final jsonStr = interp.toJsonString();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(decoded.containsKey('overview'), isTrue);
      expect(decoded.containsKey('personality'), isTrue);
      expect(decoded.containsKey('relationships'), isTrue);
      expect(decoded.containsKey('career'), isTrue);
      expect(decoded.containsKey('health'), isTrue);
    });

    test('roundtrip preserves null disclaimer', () {
      final noDisclaimer = jsonEncode({
        'overview': 'Overview',
        'personality': 'Personality',
        'relationships': 'Relationships',
        'career': 'Career',
        'health': 'Health',
      });

      final original = PalmInterpretation.fromJsonString(noDisclaimer);
      final restored =
          PalmInterpretation.fromJsonString(original.toJsonString());

      expect(restored.disclaimer, isNull);
    });
  });
}
