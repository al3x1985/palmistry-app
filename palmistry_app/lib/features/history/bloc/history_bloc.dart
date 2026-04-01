import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../data/local/database.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

class DeleteHistoryEntry extends HistoryEvent {
  final int scanId;

  const DeleteHistoryEntry(this.scanId);

  @override
  List<Object?> get props => [scanId];
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class HistoryEntry extends Equatable {
  final PalmScan scan;
  final int lineCount;

  const HistoryEntry({required this.scan, required this.lineCount});

  @override
  List<Object?> get props => [scan, lineCount];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntry> entries;

  const HistoryLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final AppDatabase _db;

  HistoryBloc({AppDatabase? db})
      : _db = db ?? getIt<AppDatabase>(),
        super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<DeleteHistoryEntry>(_onDeleteEntry);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    try {
      final scans = await _db.scanDao.getCompletedScans();
      final entries = <HistoryEntry>[];
      for (final scan in scans) {
        final lines = await _db.scanDao.getLinesForScan(scan.id);
        entries.add(HistoryEntry(scan: scan, lineCount: lines.length));
      }
      emit(HistoryLoaded(entries));
    } catch (e) {
      emit(HistoryError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onDeleteEntry(
    DeleteHistoryEntry event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _db.scanDao.deleteScan(event.scanId);
      add(const LoadHistory());
    } catch (e) {
      emit(HistoryError('Ошибка удаления: $e'));
    }
  }
}
