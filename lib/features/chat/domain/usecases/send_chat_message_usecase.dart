import '../entities/chat_turn.dart';
import '../repositories/chat_repository.dart';

class SendChatMessageUseCase {
  SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<String> call({
    required String userMessage,
    required List<ChatTurn> history,
  }) {
    return _repository.sendMessage(
      userMessage: userMessage,
      history: history,
    );
  }
}
