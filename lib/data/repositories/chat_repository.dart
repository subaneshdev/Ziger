import '../../models/chat_message_model.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String taskId, String myUserId);
  Future<ChatMessage?> sendMessage(String taskId, String content, String myUserId);
}
