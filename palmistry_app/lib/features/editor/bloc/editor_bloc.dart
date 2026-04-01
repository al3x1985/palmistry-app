import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/models/enums.dart';
import '../../../data/local/database.dart';

// ---------------------------------------------------------------------------
// Editable bezier line model
// ---------------------------------------------------------------------------

class EditableLine extends Equatable {
  final int? dbId;
  final LineType type;

  /// Control points as normalized (0–1) coordinates.
  final List<Offset> controlPoints;

  const EditableLine({
    this.dbId,
    required this.type,
    required this.controlPoints,
  });

  EditableLine copyWith({
    int? dbId,
    LineType? type,
    List<Offset>? controlPoints,
  }) {
    return EditableLine(
      dbId: dbId ?? this.dbId,
      type: type ?? this.type,
      controlPoints: controlPoints ?? this.controlPoints,
    );
  }

  @override
  List<Object?> get props => [dbId, type, controlPoints];
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class EditorState extends Equatable {
  final int scanId;
  final String? imagePath;
  final List<EditableLine> lines;
  final int? selectedLineIndex;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const EditorState({
    required this.scanId,
    this.imagePath,
    this.lines = const [],
    this.selectedLineIndex,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  EditorState copyWith({
    String? imagePath,
    List<EditableLine>? lines,
    int? selectedLineIndex,
    bool clearSelection = false,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return EditorState(
      scanId: scanId,
      imagePath: imagePath ?? this.imagePath,
      lines: lines ?? this.lines,
      selectedLineIndex:
          clearSelection ? null : (selectedLineIndex ?? this.selectedLineIndex),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        scanId,
        imagePath,
        lines,
        selectedLineIndex,
        isLoading,
        isSaving,
        error,
      ];
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class EditorEvent extends Equatable {
  const EditorEvent();

  @override
  List<Object?> get props => [];
}

class LoadScan extends EditorEvent {
  final int scanId;

  const LoadScan(this.scanId);

  @override
  List<Object?> get props => [scanId];
}

class SelectLine extends EditorEvent {
  final int? index;

  const SelectLine(this.index);

  @override
  List<Object?> get props => [index];
}

class DragControlPoint extends EditorEvent {
  final int lineIndex;
  final int pointIndex;
  final Offset newPosition;

  const DragControlPoint({
    required this.lineIndex,
    required this.pointIndex,
    required this.newPosition,
  });

  @override
  List<Object?> get props => [lineIndex, pointIndex, newPosition];
}

class DeleteLine extends EditorEvent {
  final int index;

  const DeleteLine(this.index);

  @override
  List<Object?> get props => [index];
}

class AddLine extends EditorEvent {
  final LineType lineType;

  const AddLine(this.lineType);

  @override
  List<Object?> get props => [lineType];
}

class AddControlPoint extends EditorEvent {
  final int lineIndex;
  final Offset position;

  const AddControlPoint({required this.lineIndex, required this.position});

  @override
  List<Object?> get props => [lineIndex, position];
}

class SubmitLines extends EditorEvent {
  const SubmitLines();
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final AppDatabase _db;

  EditorBloc({required int scanId, AppDatabase? db})
      : _db = db ?? getIt<AppDatabase>(),
        super(EditorState(scanId: scanId, isLoading: true)) {
    on<LoadScan>(_onLoadScan);
    on<SelectLine>(_onSelectLine);
    on<DragControlPoint>(_onDragControlPoint);
    on<DeleteLine>(_onDeleteLine);
    on<AddLine>(_onAddLine);
    on<AddControlPoint>(_onAddControlPoint);
    on<SubmitLines>(_onSubmitLines);
  }

  Future<void> _onLoadScan(LoadScan event, Emitter<EditorState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final scan = await _db.scanDao.getScanById(event.scanId);
      if (scan == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Скан не найден',
        ));
        return;
      }

      final dbLines = await _db.scanDao.getLinesForScan(event.scanId);
      final lines = dbLines.map((l) {
        final rawPoints =
            jsonDecode(l.controlPointsJson) as List<dynamic>;
        final points = rawPoints.map((p) {
          final map = p as Map<String, dynamic>;
          return Offset(
            (map['x'] as num).toDouble(),
            (map['y'] as num).toDouble(),
          );
        }).toList();

        return EditableLine(
          dbId: l.id,
          type: LineType.values.byName(l.lineType),
          controlPoints: points,
        );
      }).toList();

      emit(state.copyWith(
        imagePath: scan.imagePath,
        lines: lines,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onSelectLine(SelectLine event, Emitter<EditorState> emit) {
    if (event.index == null) {
      emit(state.copyWith(clearSelection: true));
    } else {
      emit(state.copyWith(selectedLineIndex: event.index));
    }
  }

  void _onDragControlPoint(
    DragControlPoint event,
    Emitter<EditorState> emit,
  ) {
    if (event.lineIndex >= state.lines.length) return;

    final lines = List<EditableLine>.from(state.lines);
    final line = lines[event.lineIndex];
    if (event.pointIndex >= line.controlPoints.length) return;

    final points = List<Offset>.from(line.controlPoints);
    points[event.pointIndex] = event.newPosition.clamp(
      Offset.zero,
      const Offset(1, 1),
    );

    lines[event.lineIndex] = line.copyWith(controlPoints: points);
    emit(state.copyWith(lines: lines));
  }

  void _onDeleteLine(DeleteLine event, Emitter<EditorState> emit) {
    if (event.index >= state.lines.length) return;

    final lines = List<EditableLine>.from(state.lines)..removeAt(event.index);
    int? newSelected = state.selectedLineIndex;
    if (newSelected != null) {
      if (newSelected == event.index) {
        newSelected = null;
      } else if (newSelected > event.index) {
        newSelected = newSelected - 1;
      }
    }

    emit(state.copyWith(
      lines: lines,
      selectedLineIndex: newSelected,
      clearSelection: newSelected == null,
    ));
  }

  void _onAddLine(AddLine event, Emitter<EditorState> emit) {
    // Default: a simple 2-point line in the centre
    final newLine = EditableLine(
      type: event.lineType,
      controlPoints: const [
        Offset(0.2, 0.5),
        Offset(0.5, 0.5),
        Offset(0.8, 0.5),
      ],
    );

    final lines = List<EditableLine>.from(state.lines)..add(newLine);
    emit(state.copyWith(
      lines: lines,
      selectedLineIndex: lines.length - 1,
    ));
  }

  void _onAddControlPoint(
    AddControlPoint event,
    Emitter<EditorState> emit,
  ) {
    if (event.lineIndex >= state.lines.length) return;

    final lines = List<EditableLine>.from(state.lines);
    final line = lines[event.lineIndex];
    final points = List<Offset>.from(line.controlPoints)
      ..add(event.position);
    lines[event.lineIndex] = line.copyWith(controlPoints: points);
    emit(state.copyWith(lines: lines));
  }

  Future<void> _onSubmitLines(
    SubmitLines event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));
    try {
      for (final line in state.lines) {
        final pointsJson = jsonEncode(
          line.controlPoints
              .map((p) => {'x': p.dx, 'y': p.dy})
              .toList(),
        );

        // Calculate a naive length from control points
        double length = 0;
        for (int i = 0; i < line.controlPoints.length - 1; i++) {
          final a = line.controlPoints[i];
          final b = line.controlPoints[i + 1];
          length += math.sqrt(
            math.pow(b.dx - a.dx, 2) + math.pow(b.dy - a.dy, 2),
          );
        }

        if (line.dbId != null) {
          await _db.scanDao.updateLine(
            line.dbId!,
            PalmLinesCompanion(
              controlPointsJson: Value(pointsJson),
              length: Value(length),
              isUserEdited: const Value(true),
            ),
          );
        } else {
          await _db.scanDao.insertLine(
            PalmLinesCompanion.insert(
              scanId: state.scanId,
              lineType: line.type.name,
              controlPointsJson: pointsJson,
              length: Value(length),
              isUserEdited: const Value(true),
            ),
          );
        }
      }

      await _db.scanDao.updateScanStatus(state.scanId, 'completed');
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}

extension on Offset {
  Offset clamp(Offset min, Offset max) {
    return Offset(
      dx.clamp(min.dx, max.dx),
      dy.clamp(min.dy, max.dy),
    );
  }
}
