import '../entities/chat_turn.dart';

abstract class ChatRepository {
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
  });
}
