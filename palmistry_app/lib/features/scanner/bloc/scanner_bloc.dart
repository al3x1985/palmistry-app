import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/models/enums.dart';
import '../../../data/local/database.dart';
import '../../../data/remote/cv_api_client.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends ScannerEvent {
  const InitializeCamera();
}

class CapturePhoto extends ScannerEvent {
  const CapturePhoto();
}

class PickFromGallery extends ScannerEvent {
  const PickFromGallery();
}

class ProcessImage extends ScannerEvent {
  final File imageFile;
  final Hand hand;

  const ProcessImage({required this.imageFile, required this.hand});

  @override
  List<Object?> get props => [imageFile.path, hand];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

class ScannerReady extends ScannerState {
  final Hand selectedHand;

  const ScannerReady({this.selectedHand = Hand.right});

  @override
  List<Object?> get props => [selectedHand];
}

class ScannerCapturing extends ScannerState {
  const ScannerCapturing();
}

class ScannerProcessing extends ScannerState {
  /// 0.0 – 1.0 progress
  final double progress;
  final String stepLabel;

  const ScannerProcessing({required this.progress, required this.stepLabel});

  @override
  List<Object?> get props => [progress, stepLabel];
}

class ScannerDone extends ScannerState {
  final int scanId;

  const ScannerDone({required this.scanId});

  @override
  List<Object?> get props => [scanId];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final CvApiClient _cvClient;
  final AppDatabase _db;

  ScannerBloc({CvApiClient? cvClient, AppDatabase? db})
      : _cvClient = cvClient ?? getIt<CvApiClient>(),
        _db = db ?? getIt<AppDatabase>(),
        super(const ScannerReady()) {
    on<InitializeCamera>(_onInitialize);
    on<ProcessImage>(_onProcessImage);
  }

  Future<void> _onInitialize(
    InitializeCamera event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerReady());
  }

  Future<void> _onProcessImage(
    ProcessImage event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerProcessing(progress: 0.1, stepLabel: 'Загрузка изображения...'));

    try {
      final bytes = await event.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      emit(const ScannerProcessing(progress: 0.3, stepLabel: 'Отправка на анализ...'));

      final scanResult = await _cvClient.analyzePalm(
        imageBase64: base64Image,
        landmarks: [],
        hand: event.hand.name,
      );

      emit(const ScannerProcessing(progress: 0.6, stepLabel: 'Сохранение результата...'));

      // Insert the PalmScan record
      final scanId = await _db.scanDao.insertScan(
        PalmScansCompanion.insert(
          hand: event.hand.name,
          imagePath: event.imageFile.path,
          palmShape: Value(scanResult.palmShape.name),
          palmWidthRatio: Value(scanResult.palmWidthRatio),
          fingerProportionsJson: Value(
            jsonEncode(scanResult.fingerProportions),
          ),
          status: const Value('editing'),
        ),
      );

      emit(const ScannerProcessing(progress: 0.8, stepLabel: 'Сохранение линий...'));

      // Insert detected lines
      for (final line in scanResult.lines) {
        await _db.scanDao.insertLine(
          PalmLinesCompanion.insert(
            scanId: scanId,
            lineType: line.type.name,
            controlPointsJson: jsonEncode(
              line.controlPoints.map((p) => {'x': p.x, 'y': p.y}).toList(),
            ),
            length: Value(line.length),
            depth: Value(line.depth.name),
            curvature: Value(line.curvature.name),
            startPoint: Value(line.startPoint),
            endPoint: Value(line.endPoint),
          ),
        );
      }

      emit(const ScannerProcessing(progress: 1.0, stepLabel: 'Готово!'));
      emit(ScannerDone(scanId: scanId));
    } on CvApiException catch (e) {
      emit(ScannerError(message: e.message));
    } catch (e) {
      emit(ScannerError(message: 'Ошибка обработки: $e'));
    }
  }
}
