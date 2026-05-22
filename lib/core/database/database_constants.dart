class DatabaseConstants {
  DatabaseConstants._();

  static const String dbName = 'respondi.db';
  static const int dbVersion = 1;

  static const String usersTable = 'users';

  static const String colId = 'id';
  static const String colFullName = 'full_name';
  static const String colEmail = 'email';
  static const String colPasswordHash = 'password_hash';
  static const String colAuthProvider = 'auth_provider';
  static const String colCreatedAt = 'created_at';
}
