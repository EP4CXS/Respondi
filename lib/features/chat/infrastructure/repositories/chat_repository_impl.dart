import '../../domain/entities/chat_turn.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/groq_chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({GroqChatDatasource? datasource})
      : _datasource = datasource ?? GroqChatDatasource();

  final GroqChatDatasource _datasource;

  @override
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
  }) {
    return _datasource.sendMessage(
      userMessage: userMessage,
      history: history,
    );
  }
}
