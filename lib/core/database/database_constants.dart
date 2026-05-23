class DatabaseConstants {
  DatabaseConstants._();

  static const String dbName = 'respondi.db';
  static const int dbVersion = 2;

  static const String usersTable = 'users';
  static const String chatSessionsTable = 'chat_sessions';
  static const String chatMessagesTable = 'chat_messages';

  static const String colId = 'id';
  static const String colFullName = 'full_name';
  static const String colEmail = 'email';
  static const String colPasswordHash = 'password_hash';
  static const String colAuthProvider = 'auth_provider';
  static const String colCreatedAt = 'created_at';

  static const String colUserId = 'user_id';
  static const String colTitle = 'title';
  static const String colUpdatedAt = 'updated_at';
  static const String colSessionId = 'session_id';
  static const String colRole = 'role';
  static const String colContent = 'content';
}
