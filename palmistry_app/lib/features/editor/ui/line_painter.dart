import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../bloc/editor_bloc.dart';

/// Returns the color associated with each line type.
Color lineColor(LineType type) {
  return switch (type) {
    LineType.heart => const Color(0xFFEF4444),
    LineType.head => const Color(0xFF3B82F6),
    LineType.life => const Color(0xFF10B981),
    LineType.fate => const Color(0xFFF59E0B),
  };
}

/// Draws all bezier lines and their control points over the palm image.
class LinePainter extends CustomPainter {
  final List<EditableLine> lines;
  final int? selectedLineIndex;

  const LinePainter({
    required this.lines,
    required this.selectedLineIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < lines.length; i++) {
      _drawLine(canvas, size, lines[i], i == selectedLineIndex);
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    EditableLine line,
    bool selected,
  ) {
    final color = lineColor(line.type);
    final pts = line.controlPoints
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    if (pts.length < 2) return;

    // --- Draw bezier curve ---
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);

    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
    } else {
      // Use cubic bezier segments through control points
      for (int i = 0; i < pts.length - 1; i++) {
        final p0 = pts[i];
        final p1 = pts[i + 1];

        // Control points: use neighbours if available
        final cp1 = i > 0
            ? Offset(
                p0.dx + (p1.dx - pts[i - 1].dx) / 6,
                p0.dy + (p1.dy - pts[i - 1].dy) / 6,
              )
            : Offset(
                p0.dx + (p1.dx - p0.dx) / 3,
                p0.dy + (p1.dy - p0.dy) / 3,
              );

        final cp2 = i + 2 < pts.length
            ? Offset(
                p1.dx - (pts[i + 2].dx - p0.dx) / 6,
                p1.dy - (pts[i + 2].dy - p0.dy) / 6,
              )
            : Offset(
                p1.dx - (p1.dx - p0.dx) / 3,
                p1.dy - (p1.dy - p0.dy) / 3,
              );

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
    }

    final strokeWidth = selected ? 3.0 : 2.0;

    // Glow effect when selected
    if (selected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // --- Draw control points ---
    final ptRadius = selected ? 8.0 : 5.0;
    final handleRadius = selected ? 6.0 : 4.0;

    for (int i = 0; i < pts.length; i++) {
      final pt = pts[i];
      final isEndpoint = i == 0 || i == pts.length - 1;

      if (isEndpoint) {
        // Filled circle for endpoints
        canvas.drawCircle(
          pt,
          ptRadius,
          Paint()..color = color,
        );
        canvas.drawCircle(
          pt,
          ptRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else {
        // Hollow circle for handles
        canvas.drawCircle(
          pt,
          handleRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          pt,
          handleRadius,
          Paint()..color = color.withAlpha(100),
        );
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.selectedLineIndex != selectedLineIndex;
  }
}
