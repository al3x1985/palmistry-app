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

/// Compute the rect where the image is actually drawn when using BoxFit.contain.
/// Returns (offsetX, offsetY, drawnWidth, drawnHeight).
({double ox, double oy, double w, double h}) imageRect(
    Size canvasSize, Size imageSize) {
  final scaleX = canvasSize.width / imageSize.width;
  final scaleY = canvasSize.height / imageSize.height;
  final scale = scaleX < scaleY ? scaleX : scaleY;
  final w = imageSize.width * scale;
  final h = imageSize.height * scale;
  final ox = (canvasSize.width - w) / 2;
  final oy = (canvasSize.height - h) / 2;
  return (ox: ox, oy: oy, w: w, h: h);
}

/// Draws all bezier lines and their control points over the palm image.
class LinePainter extends CustomPainter {
  final List<EditableLine> lines;
  final int? selectedLineIndex;
  final Size? imageSize; // actual image dimensions (pixels)

  const LinePainter({
    required this.lines,
    required this.selectedLineIndex,
    this.imageSize,
  });

  /// Convert normalized (0-1) point to canvas pixel position,
  /// accounting for BoxFit.contain offset.
  Offset _toCanvas(Offset normalized, Size canvasSize) {
    if (imageSize != null) {
      final r = imageRect(canvasSize, imageSize!);
      return Offset(
        r.ox + normalized.dx * r.w,
        r.oy + normalized.dy * r.h,
      );
    }
    // Fallback: no image size info — fill entire canvas
    return Offset(normalized.dx * canvasSize.width,
        normalized.dy * canvasSize.height);
  }

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
        .map((p) => _toCanvas(p, size))
        .toList();

    if (pts.length < 2) return;

    // --- Draw bezier curve ---
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);

    if (pts.length == 2) {
      path.lineTo(pts[1].dx, pts[1].dy);
    } else {
      for (int i = 0; i < pts.length - 1; i++) {
        final p0 = pts[i];
        final p1 = pts[i + 1];

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
        canvas.drawCircle(pt, ptRadius, Paint()..color = color);
        canvas.drawCircle(
          pt,
          ptRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else {
        canvas.drawCircle(
          pt,
          handleRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
            pt, handleRadius, Paint()..color = color.withAlpha(100));
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.selectedLineIndex != selectedLineIndex ||
        oldDelegate.imageSize != imageSize;
  }
}
