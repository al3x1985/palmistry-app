import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// PalmScans
// ---------------------------------------------------------------------------

class PalmScans extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'left' or 'right'
  TextColumn get hand => text()();

  TextColumn get imagePath => text()();

  /// PalmShape enum name; nullable until CV analysis completes
  TextColumn get palmShape => text().nullable()();

  RealColumn get palmWidthRatio => real().nullable()();

  /// JSON-encoded Map<String, double>
  TextColumn get fingerProportionsJson => text().nullable()();

  /// ScanStatus enum name
  TextColumn get status => text().withDefault(const Constant('processing'))();

  /// JSON-encoded PalmInterpretation
  TextColumn get aiInterpretationJson => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ---------------------------------------------------------------------------
// PalmLines
// ---------------------------------------------------------------------------

class PalmLines extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scanId =>
      integer().references(PalmScans, #id, onDelete: KeyAction.cascade)();

  /// LineType enum name
  TextColumn get lineType => text()();

  /// JSON-encoded List<{x, y}>
  TextColumn get controlPointsJson => text()();

  RealColumn get length => real().nullable()();

  /// LineDepth enum name
  TextColumn get depth => text().nullable()();

  /// LineCurvature enum name
  TextColumn get curvature => text().nullable()();

  TextColumn get startPoint => text().nullable()();

  TextColumn get endPoint => text().nullable()();

  BoolColumn get isUserEdited =>
      boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// LineReadings
// ---------------------------------------------------------------------------

class LineReadings extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scanId =>
      integer().references(PalmScans, #id, onDelete: KeyAction.cascade)();

  /// Nullable FK to PalmLines
  IntColumn get lineId =>
      integer().nullable().references(PalmLines, #id, onDelete: KeyAction.setNull)();

  TextColumn get category => text()();

  TextColumn get trait => text()();

  RealColumn get confidence => real()();

  TextColumn get ruleId => text()();

  TextColumn get description => text()();
}

// ---------------------------------------------------------------------------
// ScanMessages
// ---------------------------------------------------------------------------

class ScanMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get scanId =>
      integer().references(PalmScans, #id, onDelete: KeyAction.cascade)();

  /// MessageRole enum name: 'user' or 'assistant'
  TextColumn get role => text()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
