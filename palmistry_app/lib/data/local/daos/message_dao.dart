import 'package:drift/drift.dart';

import '../database.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [ScanMessages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  /// All messages for the given scan, ordered chronologically.
  Future<List<ScanMessage>> getMessagesForScan(int scanId) =>
      (select(scanMessages)
            ..where((t) => t.scanId.equals(scanId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> insertMessage(ScanMessagesCompanion entry) =>
      into(scanMessages).insert(entry);
}
