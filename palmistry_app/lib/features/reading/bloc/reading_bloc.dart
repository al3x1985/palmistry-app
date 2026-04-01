import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/interpretation.dart';
import '../../../core/services/rule_engine.dart';
import '../../../data/local/database.dart';
import '../../../data/remote/claude_api_client.dart';
import '../services/prompt_builder.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object?> get props => [];
}

class LoadReading extends ReadingEvent {
  final int scanId;

  const LoadReading(this.scanId);

  @override
  List<Object?> get props => [scanId];
}

class GenerateInterpretation extends ReadingEvent {
  final int scanId;

  const GenerateInterpretation(this.scanId);

  @override
  List<Object?> get props => [scanId];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class ReadingState extends Equatable {
  const ReadingState();

  @override
  List<Object?> get props => [];
}

class ReadingInitial extends ReadingState {
  const ReadingInitial();
}

class ReadingLoading extends ReadingState {
  const ReadingLoading();
}

class ReadingTraitsLoaded extends ReadingState {
  final List<LineReadingResult> traits;
  final PalmScan scanData;

  const ReadingTraitsLoaded({required this.traits, required this.scanData});

  @override
  List<Object?> get props => [traits, scanData];
}

class ReadingInterpretationLoaded extends ReadingState {
  final List<LineReadingResult> traits;
  final PalmInterpretation interpretation;
  final PalmScan scanData;

  const ReadingInterpretationLoaded({
    required this.traits,
    required this.interpretation,
    required this.scanData,
  });

  @override
  List<Object?> get props => [traits, interpretation, scanData];
}

class ReadingError extends ReadingState {
  final String message;

  const ReadingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final AppDatabase _db;
  final RuleEngine _ruleEngine;
  final ClaudeApiClient _claudeClient;

  ReadingBloc({
    AppDatabase? db,
    RuleEngine? ruleEngine,
    ClaudeApiClient? claudeClient,
  })  : _db = db ?? getIt<AppDatabase>(),
        _ruleEngine = ruleEngine ?? getIt<RuleEngine>(),
        _claudeClient = claudeClient ?? getIt<ClaudeApiClient>(),
        super(const ReadingInitial()) {
    on<LoadReading>(_onLoadReading);
    on<GenerateInterpretation>(_onGenerateInterpretation);
  }

  Future<void> _onLoadReading(
    LoadReading event,
    Emitter<ReadingState> emit,
  ) async {
    emit(const ReadingLoading());
    try {
      final scan = await _db.scanDao.getScanById(event.scanId);
      if (scan == null) {
        emit(const ReadingError('Скан не найден'));
        return;
      }

      // If interpretation is already saved, load it directly
      if (scan.aiInterpretationJson != null) {
        final interpretation =
            PalmInterpretation.fromJsonString(scan.aiInterpretationJson!);
        final savedReadings =
            await _db.scanDao.getReadingsForScan(event.scanId);
        final traits = savedReadings
            .map(
              (r) => LineReadingResult(
                ruleId: r.ruleId,
                lineType: null,
                category: r.category,
                trait: r.trait,
                confidence: r.confidence,
                description: r.description,
              ),
            )
            .toList();
        emit(ReadingInterpretationLoaded(
          traits: traits,
          interpretation: interpretation,
          scanData: scan,
        ));
        return;
      }

      // Load DB lines and run rule engine
      final dbLines = await _db.scanDao.getLinesForScan(event.scanId);
      final lineDataList = dbLines.map((l) {
        return LineData(
          lineType: l.lineType,
          length: _lengthCategory(l.length),
          depth: l.depth ?? 'medium',
          curvature: l.curvature ?? 'curved',
          startPoint: l.startPoint ?? '',
          endPoint: l.endPoint ?? '',
        );
      }).toList();

      Map<String, double>? fingerProportions;
      if (scan.fingerProportionsJson != null) {
        final raw = jsonDecode(scan.fingerProportionsJson!) as Map<String, dynamic>;
        fingerProportions = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }

      final traits = _ruleEngine.evaluate(
        palmShape: scan.palmShape,
        fingerProportions: fingerProportions,
        lines: lineDataList,
      );

      // Persist line readings to DB (clear old ones first via cascade is not available,
      // so we just insert new ones if none exist)
      final existingReadings =
          await _db.scanDao.getReadingsForScan(event.scanId);
      if (existingReadings.isEmpty) {
        for (final t in traits) {
          await _db.scanDao.insertReading(
            LineReadingsCompanion.insert(
              scanId: event.scanId,
              category: t.category,
              trait: t.trait,
              confidence: t.confidence,
              ruleId: t.ruleId,
              description: t.description,
            ),
          );
        }
      }

      emit(ReadingTraitsLoaded(traits: traits, scanData: scan));
    } catch (e) {
      emit(ReadingError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onGenerateInterpretation(
    GenerateInterpretation event,
    Emitter<ReadingState> emit,
  ) async {
    final current = state;
    List<LineReadingResult> traits;
    PalmScan? scan;

    if (current is ReadingTraitsLoaded) {
      traits = current.traits;
      scan = current.scanData;
    } else {
      emit(const ReadingError('Сначала загрузите данные'));
      return;
    }

    emit(const ReadingLoading());
    try {
      final userPrompt = PromptBuilder.buildUserPrompt(
        hand: scan.hand,
        palmShape: scan.palmShape ?? 'square',
        traits: traits,
      );

      final jsonString = await _claudeClient.getInterpretation(
        systemPrompt: PromptBuilder.buildSystemPrompt,
        userPrompt: userPrompt,
      );

      final interpretation = PalmInterpretation.fromJsonString(jsonString);

      await _db.scanDao.updateScanInterpretation(
        event.scanId,
        interpretationJson: interpretation.toJsonString(),
      );

      emit(ReadingInterpretationLoaded(
        traits: traits,
        interpretation: interpretation,
        scanData: scan,
      ));
    } on ClaudeApiException catch (e) {
      emit(ReadingError('Ошибка API: ${e.message}'));
    } catch (e) {
      emit(ReadingError('Ошибка интерпретации: $e'));
    }
  }

  String _lengthCategory(double? length) {
    if (length == null) return 'medium';
    if (length > 0.6) return 'long';
    if (length < 0.3) return 'short';
    return 'medium';
  }
}

// Hand extension to get display name
extension HandDisplay on Hand {
  String get displayName {
    switch (this) {
      case Hand.left:
        return 'Левая';
      case Hand.right:
        return 'Правая';
    }
  }
}

// PalmShape extension
extension PalmShapeDisplay on PalmShape {
  String get displayName {
    switch (this) {
      case PalmShape.square:
        return 'Квадратная (Земля)';
      case PalmShape.rectangle:
        return 'Прямоугольная (Воздух)';
      case PalmShape.spatulate:
        return 'Лопатообразная (Огонь)';
      case PalmShape.conic:
        return 'Коническая (Вода)';
    }
  }
}
