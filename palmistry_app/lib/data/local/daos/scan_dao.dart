import 'package:drift/drift.dart';

import '../database.dart';

part 'scan_dao.g.dart';

@DriftAccessor(tables: [PalmScans, PalmLines, LineReadings])
class ScanDao extends DatabaseAccessor<AppDatabase> with _$ScanDaoMixin {
  ScanDao(super.db);

  // ---------------------------------------------------------------------------
  // PalmScans
  // ---------------------------------------------------------------------------

  Future<int> insertScan(PalmScansCompanion entry) =>
      into(palmScans).insert(entry);

  Future<PalmScan?> getScanById(int id) =>
      (select(palmScans)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// All scans with status = 'completed', newest first.
  Future<List<PalmScan>> getCompletedScans() =>
      (select(palmScans)
            ..where((t) => t.status.equals('completed'))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> updateScanStatus(int id, String status) =>
      (update(palmScans)..where((t) => t.id.equals(id)))
          .write(PalmScansCompanion(status: Value(status)));

  Future<void> updateScanInterpretation(
    int id, {
    required String interpretationJson,
    String? palmShape,
    double? palmWidthRatio,
    String? fingerProportionsJson,
  }) =>
      (update(palmScans)..where((t) => t.id.equals(id))).write(
        PalmScansCompanion(
          aiInterpretationJson: Value(interpretationJson),
          palmShape: palmShape != null ? Value(palmShape) : const Value.absent(),
          palmWidthRatio:
              palmWidthRatio != null ? Value(palmWidthRatio) : const Value.absent(),
          fingerProportionsJson: fingerProportionsJson != null
              ? Value(fingerProportionsJson)
              : const Value.absent(),
        ),
      );

  Future<int> deleteScan(int id) =>
      (delete(palmScans)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // PalmLines
  // ---------------------------------------------------------------------------

  Future<int> insertLine(PalmLinesCompanion entry) =>
      into(palmLines).insert(entry);

  Future<List<PalmLine>> getLinesForScan(int scanId) =>
      (select(palmLines)..where((t) => t.scanId.equals(scanId))).get();

  Future<void> updateLine(int id, PalmLinesCompanion entry) =>
      (update(palmLines)..where((t) => t.id.equals(id))).write(entry);

  Future<int> deleteLine(int id) =>
      (delete(palmLines)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // LineReadings
  // ---------------------------------------------------------------------------

  Future<int> insertReading(LineReadingsCompanion entry) =>
      into(lineReadings).insert(entry);

  Future<List<LineReading>> getReadingsForScan(int scanId) =>
      (select(lineReadings)..where((t) => t.scanId.equals(scanId))).get();
}
