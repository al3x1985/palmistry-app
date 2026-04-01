// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanDaoMixin on DatabaseAccessor<AppDatabase> {
  $PalmScansTable get palmScans => attachedDatabase.palmScans;
  $PalmLinesTable get palmLines => attachedDatabase.palmLines;
  $LineReadingsTable get lineReadings => attachedDatabase.lineReadings;
  ScanDaoManager get managers => ScanDaoManager(this);
}

class ScanDaoManager {
  final _$ScanDaoMixin _db;
  ScanDaoManager(this._db);
  $$PalmScansTableTableManager get palmScans =>
      $$PalmScansTableTableManager(_db.attachedDatabase, _db.palmScans);
  $$PalmLinesTableTableManager get palmLines =>
      $$PalmLinesTableTableManager(_db.attachedDatabase, _db.palmLines);
  $$LineReadingsTableTableManager get lineReadings =>
      $$LineReadingsTableTableManager(_db.attachedDatabase, _db.lineReadings);
}
