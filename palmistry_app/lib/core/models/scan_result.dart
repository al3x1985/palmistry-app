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
    final rawProportions =
        json['fingerProportions'] as Map<String, dynamic>? ?? {};
    final fingerProportions = rawProportions.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    final rawLines = json['lines'] as List<dynamic>? ?? [];
    final lines = rawLines
        .map((l) => PalmLineData.fromJson(l as Map<String, dynamic>))
        .toList();

    return ScanResult(
      palmShape: PalmShape.values.byName(json['palmShape'] as String),
      palmWidthRatio: (json['palmWidthRatio'] as num).toDouble(),
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
