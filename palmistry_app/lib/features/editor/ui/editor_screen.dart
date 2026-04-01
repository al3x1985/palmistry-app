import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/editor_bloc.dart';
import 'line_list_panel.dart';
import 'line_painter.dart';

class EditorScreen extends StatelessWidget {
  final int scanId;

  const EditorScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorBloc(scanId: scanId)..add(LoadScan(scanId)),
      child: const _EditorView(),
    );
  }
}

class _EditorView extends StatelessWidget {
  const _EditorView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditorBloc, EditorState>(
      listenWhen: (prev, curr) =>
          prev.isSaving && !curr.isSaving && curr.error == null,
      listener: (context, state) {
        context.go('/result/${state.scanId}');
      },
      child: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null) {
            return Scaffold(
              body: Center(
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return _EditorContent(state: state);
        },
      ),
    );
  }
}

class _EditorContent extends StatelessWidget {
  final EditorState state;

  const _EditorContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditorBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор линий'),
        actions: [
          if (state.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => bloc.add(const SubmitLines()),
              child: const Row(
                children: [
                  Text(
                    'Далее',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Color(0xFF7C3AED), size: 18),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Image + line overlay
          Expanded(
            child: _LineEditorCanvas(state: state, bloc: bloc),
          ),

          // Line list at bottom
          LineListPanel(
            lines: state.lines,
            selectedIndex: state.selectedLineIndex,
            onSelect: (i) => bloc.add(SelectLine(i)),
            onDelete: (i) => bloc.add(DeleteLine(i)),
            onAdd: () => _showAddLineSheet(context, bloc),
          ),
        ],
      ),
    );
  }

  void _showAddLineSheet(BuildContext context, EditorBloc bloc) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLineSheet(
        onSelect: (type) => bloc.add(AddLine(type)),
      ),
    );
  }
}

class _LineEditorCanvas extends StatefulWidget {
  final EditorState state;
  final EditorBloc bloc;

  const _LineEditorCanvas({required this.state, required this.bloc});

  @override
  State<_LineEditorCanvas> createState() => _LineEditorCanvasState();
}

class _LineEditorCanvasState extends State<_LineEditorCanvas> {
  int? _draggingLineIndex;
  int? _draggingPointIndex;
  Size? _imageSize; // actual image dimensions

  static const double _hitRadius = 0.04;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return GestureDetector(
          onPanStart: (details) => _onPanStart(details, size),
          onPanUpdate: (details) => _onPanUpdate(details, size),
          onPanEnd: (_) {
            _draggingLineIndex = null;
            _draggingPointIndex = null;
          },
          onTapUp: (details) => _onTap(details, size),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Palm image
              if (state.imagePath != null)
                Image.file(
                  File(state.imagePath!),
                  fit: BoxFit.contain,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    // Get image dimensions once loaded
                    if (frame != null && _imageSize == null) {
                      _loadImageSize(state.imagePath!);
                    }
                    return child;
                  },
                )
              else
                Container(
                  color: const Color(0xFF0F0F1A),
                  child: const Center(
                    child: Icon(
                      Icons.back_hand_outlined,
                      size: 100,
                      color: Colors.white12,
                    ),
                  ),
                ),

              // Lines overlay — pass imageSize for BoxFit.contain offset
              CustomPaint(
                painter: LinePainter(
                  lines: state.lines,
                  selectedLineIndex: state.selectedLineIndex,
                  imageSize: _imageSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details, Size size) {
    final norm = _normalize(details.localPosition, size);
    _findNearestControlPoint(norm, size);
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_draggingLineIndex == null || _draggingPointIndex == null) return;
    final norm = _normalize(details.localPosition, size);
    widget.bloc.add(DragControlPoint(
      lineIndex: _draggingLineIndex!,
      pointIndex: _draggingPointIndex!,
      newPosition: norm,
    ));
  }

  void _onTap(TapUpDetails details, Size size) {
    final norm = _normalize(details.localPosition, size);
    _findNearestControlPoint(norm, size);
    // If nothing found, deselect
    if (_draggingLineIndex == null) {
      widget.bloc.add(const SelectLine(null));
    }
  }

  void _findNearestControlPoint(Offset norm, Size size) {
    double bestDist = double.infinity;
    int? bestLine;
    int? bestPoint;

    final lines = widget.state.lines;

    for (int li = 0; li < lines.length; li++) {
      for (int pi = 0; pi < lines[li].controlPoints.length; pi++) {
        final pt = lines[li].controlPoints[pi];
        final dist = math.sqrt(
          math.pow(norm.dx - pt.dx, 2) + math.pow(norm.dy - pt.dy, 2),
        );
        if (dist < _hitRadius && dist < bestDist) {
          bestDist = dist;
          bestLine = li;
          bestPoint = pi;
        }
      }
    }

    if (bestLine != null && bestPoint != null) {
      _draggingLineIndex = bestLine;
      _draggingPointIndex = bestPoint;
      widget.bloc.add(SelectLine(bestLine));
    } else {
      _draggingLineIndex = null;
      _draggingPointIndex = null;
    }
  }

  Offset _normalize(Offset local, Size canvasSize) {
    if (_imageSize != null) {
      final r = imageRect(canvasSize, _imageSize!);
      return Offset(
        ((local.dx - r.ox) / r.w).clamp(0.0, 1.0),
        ((local.dy - r.oy) / r.h).clamp(0.0, 1.0),
      );
    }
    return Offset(
      (local.dx / canvasSize.width).clamp(0.0, 1.0),
      (local.dy / canvasSize.height).clamp(0.0, 1.0),
    );
  }

  void _loadImageSize(String path) {
    final file = File(path);
    file.readAsBytes().then((bytes) {
      ui.decodeImageFromList(bytes, (ui.Image image) {
        if (mounted) {
          setState(() {
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
      });
    });
  }
}
