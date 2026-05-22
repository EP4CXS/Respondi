import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/exceptions/auth_failure.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({Database? database}) {
    _databaseProvider = database != null
        ? () => Future<Database>.value(database)
        : () => AppDatabase.database;
  }

  late final Future<Database> Function() _databaseProvider;
  final _uuid = const Uuid();

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final db = await _databaseProvider();
    final normalizedEmail = email.trim().toLowerCase();

    final existing = await _findByEmail(db, normalizedEmail);
    if (existing != null) {
      throw const AuthFailure('An account with this email already exists');
    }

    final user = AppUser(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: normalizedEmail,
    );

    await db.insert(
      DatabaseConstants.usersTable,
      {
        DatabaseConstants.colId: user.id,
        DatabaseConstants.colFullName: user.fullName,
        DatabaseConstants.colEmail: user.email,
        DatabaseConstants.colPasswordHash: PasswordHasher.hashPassword(password),
        DatabaseConstants.colAuthProvider: 'email',
        DatabaseConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
      },
    );

    return user;
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await _databaseProvider();
    final normalizedEmail = email.trim().toLowerCase();

    final row = await _findByEmail(db, normalizedEmail);
    if (row == null) {
      throw const AuthFailure('No account found for this email');
    }

    final hash = row[DatabaseConstants.colPasswordHash] as String?;
    if (hash == null || hash.isEmpty) {
      throw const AuthFailure('Invalid account credentials');
    }

    if (!PasswordHasher.verify(password, hash)) {
      throw const AuthFailure('Incorrect password');
    }

    return _rowToUser(row);
  }

  Future<Map<String, Object?>?> _findByEmail(
    Database db,
    String email,
  ) async {
    final rows = await db.query(
      DatabaseConstants.usersTable,
      where: '${DatabaseConstants.colEmail} = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  AppUser _rowToUser(Map<String, Object?> row) {
    return AppUser(
      id: row[DatabaseConstants.colId]! as String,
      fullName: row[DatabaseConstants.colFullName]! as String,
      email: row[DatabaseConstants.colEmail]! as String,
    );
  }
}
