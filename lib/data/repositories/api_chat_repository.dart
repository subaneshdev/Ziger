import 'chat_repository.dart';
import '../../services/api_service.dart';
import '../../models/chat_message_model.dart';

class ApiChatRepository implements ChatRepository {
  final ApiService _api = ApiService();

  @override
  Future<List<ChatMessage>> getMessages(String taskId, String myUserId) async {
    print('ApiChatRepository: Requesting messages for task $taskId');
    final response = await _api.get('/chat/$taskId/messages');
    if (response == null) {
      print('ApiChatRepository: Response was null');
      return [];
    }
    print('ApiChatRepository: Response received with ${(response as List).length} items');
    return (response as List).map((json) => ChatMessage.fromJson(json, myUserId)).toList();
  }

  @override
  Future<ChatMessage?> sendMessage(String taskId, String content, String myUserId) async {
    print('ApiChatRepository: Sending message for task $taskId');
    final response = await _api.post('/chat/$taskId/send', {'content': content});
    if (response != null) {
      print('ApiChatRepository: Send success');
      return ChatMessage.fromJson(response, myUserId);
    }
    print('ApiChatRepository: Send failed (response null)');
    return null;
  }
}
