import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../../domain/entities/stored_chat_message.dart';

class ChatHistoryDatasource {
  ChatHistoryDatasource({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Future<String> createSession({
    required String userId,
    required String title,
  }) async {
    final db = await AppDatabase.database;
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(DatabaseConstants.chatSessionsTable, {
      DatabaseConstants.colId: id,
      DatabaseConstants.colUserId: userId,
      DatabaseConstants.colTitle: _truncateTitle(title),
      DatabaseConstants.colCreatedAt: now,
      DatabaseConstants.colUpdatedAt: now,
    });

    return id;
  }

  Future<void> touchSession(String sessionId) async {
    final db = await AppDatabase.database;
    await db.update(
      DatabaseConstants.chatSessionsTable,
      {DatabaseConstants.colUpdatedAt: DateTime.now().millisecondsSinceEpoch},
      where: '${DatabaseConstants.colId} = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> insertMessage({
    required String sessionId,
    required String role,
    required String content,
  }) async {
    final db = await AppDatabase.database;
    await db.insert(DatabaseConstants.chatMessagesTable, {
      DatabaseConstants.colId: _uuid.v4(),
      DatabaseConstants.colSessionId: sessionId,
      DatabaseConstants.colRole: role,
      DatabaseConstants.colContent: content,
      DatabaseConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
    });
    await touchSession(sessionId);
  }

  Future<List<ChatSessionSummary>> listSessions(String userId) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      DatabaseConstants.chatSessionsTable,
      where: '${DatabaseConstants.colUserId} = ?',
      whereArgs: [userId],
      orderBy: '${DatabaseConstants.colUpdatedAt} DESC',
    );

    return rows
        .map(
          (row) => ChatSessionSummary(
            id: row[DatabaseConstants.colId]! as String,
            title: row[DatabaseConstants.colTitle]! as String,
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              row[DatabaseConstants.colUpdatedAt]! as int,
            ),
          ),
        )
        .toList();
  }

  Future<List<StoredChatMessage>> getMessages(String sessionId) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      DatabaseConstants.chatMessagesTable,
      where: '${DatabaseConstants.colSessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${DatabaseConstants.colCreatedAt} ASC',
    );

    return rows
        .map(
          (row) => StoredChatMessage(
            role: row[DatabaseConstants.colRole]! as String,
            content: row[DatabaseConstants.colContent]! as String,
          ),
        )
        .toList();
  }

  String _truncateTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 48) return trimmed;
    return '${trimmed.substring(0, 48)}...';
  }
}
