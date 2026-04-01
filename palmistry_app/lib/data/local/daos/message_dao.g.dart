// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dao.dart';

// ignore_for_file: type=lint
mixin _$MessageDaoMixin on DatabaseAccessor<AppDatabase> {
  $PalmScansTable get palmScans => attachedDatabase.palmScans;
  $ScanMessagesTable get scanMessages => attachedDatabase.scanMessages;
  MessageDaoManager get managers => MessageDaoManager(this);
}

class MessageDaoManager {
  final _$MessageDaoMixin _db;
  MessageDaoManager(this._db);
  $$PalmScansTableTableManager get palmScans =>
      $$PalmScansTableTableManager(_db.attachedDatabase, _db.palmScans);
  $$ScanMessagesTableTableManager get scanMessages =>
      $$ScanMessagesTableTableManager(_db.attachedDatabase, _db.scanMessages);
}
