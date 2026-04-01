import 'dart:convert';

class PalmInterpretation {
  final String overview;
  final String personality;
  final String relationships;
  final String career;
  final String health;
  final String? disclaimer;

  const PalmInterpretation({
    required this.overview,
    required this.personality,
    required this.relationships,
    required this.career,
    required this.health,
    this.disclaimer,
  });

  factory PalmInterpretation.fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;

    final overview = map['overview'] as String?;
    final personality = map['personality'] as String?;
    final relationships = map['relationships'] as String?;
    final career = map['career'] as String?;
    final health = map['health'] as String?;

    if (overview == null ||
        personality == null ||
        relationships == null ||
        career == null ||
        health == null) {
      throw const FormatException(
        'Missing required fields in palm interpretation JSON. '
        'Required: overview, personality, relationships, career, health.',
      );
    }

    return PalmInterpretation(
      overview: overview,
      personality: personality,
      relationships: relationships,
      career: career,
      health: health,
      disclaimer: map['disclaimer'] as String?,
    );
  }

  String toJsonString() => jsonEncode({
        'overview': overview,
        'personality': personality,
        'relationships': relationships,
        'career': career,
        'health': health,
        'disclaimer': disclaimer,
      });

  PalmInterpretation copyWith({
    String? overview,
    String? personality,
    String? relationships,
    String? career,
    String? health,
    String? disclaimer,
  }) {
    return PalmInterpretation(
      overview: overview ?? this.overview,
      personality: personality ?? this.personality,
      relationships: relationships ?? this.relationships,
      career: career ?? this.career,
      health: health ?? this.health,
      disclaimer: disclaimer ?? this.disclaimer,
    );
  }
}
