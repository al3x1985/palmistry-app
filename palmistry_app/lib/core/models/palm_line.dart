import 'dart:convert';

import 'enums.dart';

class PalmLineData {
  final LineType type;
  final List<({double x, double y})> controlPoints;
  final double length;
  final LineDepth depth;
  final LineCurvature curvature;
  final String startPoint;
  final String endPoint;
  final bool isUserEdited;

  const PalmLineData({
    required this.type,
    required this.controlPoints,
    required this.length,
    required this.depth,
    required this.curvature,
    required this.startPoint,
    required this.endPoint,
    this.isUserEdited = false,
  });

  factory PalmLineData.fromJson(Map<String, dynamic> json) {
    // Server uses snake_case (control_points, line_type, start_point, end_point)
    final rawPoints = (json['control_points'] ?? json['controlPoints']) as List<dynamic>;
    final controlPoints = rawPoints.map((p) {
      final point = p as Map<String, dynamic>;
      return (x: (point['x'] as num).toDouble(), y: (point['y'] as num).toDouble());
    }).toList();

    final typeStr = (json['line_type'] ?? json['type']) as String;
    final startPt = (json['start_point'] ?? json['startPoint']) as String;
    final endPt = (json['end_point'] ?? json['endPoint']) as String;

    return PalmLineData(
      type: LineType.values.byName(typeStr),
      controlPoints: controlPoints,
      length: (json['length'] as num).toDouble(),
      depth: LineDepth.values.byName(json['depth'] as String),
      curvature: LineCurvature.values.byName(json['curvature'] as String),
      startPoint: startPt,
      endPoint: endPt,
      isUserEdited: (json['is_user_edited'] ?? json['isUserEdited']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'controlPoints': controlPoints
            .map((p) => {'x': p.x, 'y': p.y})
            .toList(),
        'length': length,
        'depth': depth.name,
        'curvature': curvature.name,
        'startPoint': startPoint,
        'endPoint': endPoint,
        'isUserEdited': isUserEdited,
      };

  String toJsonString() => jsonEncode(toJson());

  static PalmLineData fromJsonString(String jsonString) =>
      PalmLineData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  PalmLineData copyWith({
    LineType? type,
    List<({double x, double y})>? controlPoints,
    double? length,
    LineDepth? depth,
    LineCurvature? curvature,
    String? startPoint,
    String? endPoint,
    bool? isUserEdited,
  }) {
    return PalmLineData(
      type: type ?? this.type,
      controlPoints: controlPoints ?? this.controlPoints,
      length: length ?? this.length,
      depth: depth ?? this.depth,
      curvature: curvature ?? this.curvature,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      isUserEdited: isUserEdited ?? this.isUserEdited,
    );
  }
}
