import 'enums.dart';
import 'palm_line.dart';

/// Parsed response from the CV server /analyze endpoint.
class ScanResult {
  final PalmShape palmShape;
  final double palmWidthRatio;
  final Map<String, double> fingerProportions;
  final List<PalmLineData> lines;

  const ScanResult({
    required this.palmShape,
    required this.palmWidthRatio,
    required this.fingerProportions,
    required this.lines,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    // Server uses snake_case, client uses camelCase — handle both
    final rawProportions =
        (json['finger_proportions'] ?? json['fingerProportions']) as Map<String, dynamic>? ?? {};
    final fingerProportions = rawProportions.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    final rawLines = (json['lines'] as List<dynamic>?) ?? [];
    final lines = rawLines
        .map((l) => PalmLineData.fromJson(l as Map<String, dynamic>))
        .toList();

    final shapeStr = (json['palm_shape'] ?? json['palmShape']) as String;
    final widthRatio = (json['palm_width_ratio'] ?? json['palmWidthRatio']) as num;

    return ScanResult(
      palmShape: PalmShape.values.byName(shapeStr),
      palmWidthRatio: widthRatio.toDouble(),
      fingerProportions: fingerProportions,
      lines: lines,
    );
  }

  Map<String, dynamic> toJson() => {
        'palmShape': palmShape.name,
        'palmWidthRatio': palmWidthRatio,
        'fingerProportions': fingerProportions,
        'lines': lines.map((l) => l.toJson()).toList(),
      };
}
