import 'dart:convert';

import 'package:flutter/services.dart';

/// A single palmistry rule loaded from JSON.
class PalmistryRule {
  final String id;
  final Map<String, String> conditions;
  final String category;
  final String trait;
  final double confidence;
  final String description;

  const PalmistryRule({
    required this.id,
    required this.conditions,
    required this.category,
    required this.trait,
    required this.confidence,
    required this.description,
  });

  factory PalmistryRule.fromJson(Map<String, dynamic> json) {
    final rawConditions = json['conditions'] as Map<String, dynamic>;
    final conditions = rawConditions.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return PalmistryRule(
      id: json['id'] as String,
      conditions: conditions,
      category: json['category'] as String,
      trait: json['trait'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conditions': conditions,
        'category': category,
        'trait': trait,
        'confidence': confidence,
        'description': description,
      };
}

/// Simplified line data for rule matching.
class LineData {
  final String lineType;
  final String length;
  final String depth;
  final String curvature;
  final String startPoint;
  final String endPoint;

  const LineData({
    required this.lineType,
    required this.length,
    required this.depth,
    required this.curvature,
    required this.startPoint,
    required this.endPoint,
  });
}

/// Result of a rule evaluation match.
class LineReadingResult {
  final String ruleId;
  final String? lineType;
  final String category;
  final String trait;
  final double confidence;
  final String description;

  const LineReadingResult({
    required this.ruleId,
    this.lineType,
    required this.category,
    required this.trait,
    required this.confidence,
    required this.description,
  });
}

/// Loads JSON palmistry rules from assets and evaluates them against palm data.
class RuleEngine {
  List<PalmistryRule> _rules = [];

  List<PalmistryRule> get rules => List.unmodifiable(_rules);

  static const _ruleFiles = [
    'assets/rules/heart_line.json',
    'assets/rules/head_line.json',
    'assets/rules/life_line.json',
    'assets/rules/fate_line.json',
    'assets/rules/palm_shape.json',
    'assets/rules/fingers.json',
  ];

  /// Load rules from the asset bundle (production use).
  Future<void> loadRules(AssetBundle bundle) async {
    final allRules = <PalmistryRule>[];

    for (final path in _ruleFiles) {
      try {
        final jsonString = await bundle.loadString(path);
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        for (final item in jsonList) {
          allRules.add(
            PalmistryRule.fromJson(item as Map<String, dynamic>),
          );
        }
      } catch (_) {
        // Skip files that don't exist or fail to parse.
      }
    }

    _rules = allRules;
  }

  /// Load rules directly from a list of JSON maps (for testing).
  void loadRulesFromJsonList(List<Map<String, dynamic>> rulesList) {
    _rules = rulesList.map(PalmistryRule.fromJson).toList();
  }

  /// Evaluate all loaded rules against the provided palm data.
  ///
  /// Returns a list of [LineReadingResult] for every rule whose conditions
  /// are satisfied by the input.
  List<LineReadingResult> evaluate({
    required String? palmShape,
    required Map<String, double>? fingerProportions,
    required List<LineData> lines,
  }) {
    final results = <LineReadingResult>[];

    for (final rule in _rules) {
      final conditions = rule.conditions;

      // Determine what kind of rule this is based on conditions.
      if (conditions.containsKey('palmShape')) {
        if (_matchesPalmShape(conditions, palmShape, fingerProportions)) {
          results.add(_toResult(rule, null));
        }
      } else if (conditions.containsKey('finger')) {
        if (_matchesFinger(conditions, fingerProportions)) {
          results.add(_toResult(rule, null));
        }
      } else if (conditions.containsKey('lineType')) {
        final lineType = conditions['lineType']!;
        for (final line in lines) {
          if (line.lineType == lineType && _matchesLine(conditions, line)) {
            results.add(_toResult(rule, lineType));
          }
        }
      }
    }

    return results;
  }

  bool _matchesPalmShape(
    Map<String, String> conditions,
    String? palmShape,
    Map<String, double>? fingerProportions,
  ) {
    if (palmShape == null) return false;

    if (conditions['palmShape'] != palmShape) return false;

    // Check optional finger proportion conditions on palm shape rules.
    if (conditions.containsKey('fingerLength')) {
      if (fingerProportions == null) return false;
      final expected = conditions['fingerLength']!;
      // "long" means average proportion > 0.5, "short" means <= 0.5.
      final avg = fingerProportions.values.isEmpty
          ? 0.0
          : fingerProportions.values.reduce((a, b) => a + b) /
              fingerProportions.values.length;
      if (expected == 'long' && avg <= 0.5) return false;
      if (expected == 'short' && avg > 0.5) return false;
    }

    return true;
  }

  bool _matchesFinger(
    Map<String, String> conditions,
    Map<String, double>? fingerProportions,
  ) {
    if (fingerProportions == null) return false;

    final finger = conditions['finger']!;
    final expected = conditions['proportion'];

    if (expected == null) return false;

    final value = fingerProportions[finger];
    if (value == null) return false;

    switch (expected) {
      case 'long':
        return value > 0.55;
      case 'short':
        return value < 0.45;
      case 'equal':
        // For "equal" rules, check that index and ring are close.
        final index = fingerProportions['index'];
        final ring = fingerProportions['ring'];
        if (index == null || ring == null) return false;
        return (index - ring).abs() < 0.05;
      default:
        return false;
    }
  }

  bool _matchesLine(Map<String, String> conditions, LineData line) {
    for (final entry in conditions.entries) {
      switch (entry.key) {
        case 'lineType':
          // Already matched above.
          continue;
        case 'length':
          if (line.length != entry.value) return false;
        case 'depth':
          if (line.depth != entry.value) return false;
        case 'curvature':
          if (line.curvature != entry.value) return false;
        case 'startPoint':
          if (line.startPoint != entry.value) return false;
        case 'endPoint':
          if (line.endPoint != entry.value) return false;
      }
    }
    return true;
  }

  LineReadingResult _toResult(PalmistryRule rule, String? lineType) {
    return LineReadingResult(
      ruleId: rule.id,
      lineType: lineType,
      category: rule.category,
      trait: rule.trait,
      confidence: rule.confidence,
      description: rule.description,
    );
  }
}
