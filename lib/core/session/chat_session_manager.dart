/// In-memory active chat session for the current app visit.
class ChatSessionManager {
  ChatSessionManager._();

  static String? userId;
  static String? activeSessionId;

  static void beginUserSession(String id) {
    userId = id;
    activeSessionId = null;
  }

  static void setActiveSession(String sessionId) {
    activeSessionId = sessionId;
  }

  static void clearActiveSession() {
    activeSessionId = null;
  }

  static void clear() {
    userId = null;
    activeSessionId = null;
  }
}
