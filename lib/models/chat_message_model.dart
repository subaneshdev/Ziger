
import 'package:intl/intl.dart';

class ChatMessage {
  final String id;
  final String taskId;
  final String senderId;
  final String senderName;
  final String content;
  final String createdAt;
  final bool isMine; // Helper for UI, determined at runtime or parsing

  ChatMessage({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
    this.isMine = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    final sender = json['sender'] ?? {};
    final senderId = sender['id'] as String? ?? '';
    
    return ChatMessage(
      id: json['id'] as String,
      taskId: json['taskId'] as String? ?? '', // Maybe just UUID string
      senderId: senderId,
      senderName: sender['fullName'] as String? ?? 'Unknown',
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
      isMine: senderId == myUserId,
    );
  }

  String get formattedTime {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }
}
