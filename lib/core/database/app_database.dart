import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'database_constants.dart';
import 'database_path_resolver.dart';

class AppDatabase {
  AppDatabase._();

  static Database? _database;

  /// Call once at app startup (see [main.dart]).
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web: no shared worker (more reliable in Chrome debug than databaseFactoryFfiWeb).
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Android / iOS use the default sqflite factory.

    await database;
  }

  static Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  static Future<Database> _open() async {
    final path = await DatabasePathResolver.resolve();

    final db = await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    if (kDebugMode) {
      if (kIsWeb) {
        debugPrint(
          'SQLite (web): data is in browser storage — '
          'not data/respondi.db on disk',
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('SQLite (Android): $path');
        debugPrint(
          'To view on PC: run scripts\\sync_android_db.cmd and open '
          'data\\respondi.db in DB Browser',
        );
      } else {
        debugPrint('SQLite database path: $path');
      }
    }

    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createChatTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createChatTables(db);
    }
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.usersTable} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colFullName} TEXT NOT NULL,
        ${DatabaseConstants.colEmail} TEXT NOT NULL UNIQUE,
        ${DatabaseConstants.colPasswordHash} TEXT,
        ${DatabaseConstants.colAuthProvider} TEXT NOT NULL,
        ${DatabaseConstants.colCreatedAt} INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createChatTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.chatSessionsTable} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colUserId} TEXT NOT NULL,
        ${DatabaseConstants.colTitle} TEXT NOT NULL,
        ${DatabaseConstants.colCreatedAt} INTEGER NOT NULL,
        ${DatabaseConstants.colUpdatedAt} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colUserId})
          REFERENCES ${DatabaseConstants.usersTable}(${DatabaseConstants.colId})
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.chatMessagesTable} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colSessionId} TEXT NOT NULL,
        ${DatabaseConstants.colRole} TEXT NOT NULL,
        ${DatabaseConstants.colContent} TEXT NOT NULL,
        ${DatabaseConstants.colCreatedAt} INTEGER NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colSessionId})
          REFERENCES ${DatabaseConstants.chatSessionsTable}(${DatabaseConstants.colId})
      )
    ''');
  }
}
