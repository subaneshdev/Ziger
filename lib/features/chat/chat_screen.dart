import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/chat_repository.dart';
import '../../models/chat_message_model.dart';
import '../../features/auth/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String taskId;
  final String chatTitle;

  const ChatScreen({super.key, required this.taskId, required this.chatTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  // TODO: Add polling or WebSocket for real-time

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    try {
      final msgs = await context.read<ChatRepository>().getMessages(widget.taskId, user.id);
      if (mounted) {
        setState(() {
          _messages = msgs; // Backend sorts by date usually? Assuming ASC or DESC.
          // If backend is DESC, reverse. Assuming backend sends latest first or last?
          // Backend repo says "OrderByCreatedAtDesc". So first item is NEWEST.
          // ListView(reverse: true) expects newest at bottom if we insert at 0?
          // No, usually chat puts newest at bottom.
          // If List is [Newest, ..., Oldest] and we want Newest at Bottom in Column, we reverse it.
          // Let's assume Backend sends [Newest, ..., Oldest].
          // We will render ListView(reverse: true) and pass list as is?
          // If we use standard list view, item 0 is top.
          // Standard chat: bottom is newest.
          // So if we have [Newest, Oldest], index 0 is at bottom (with reverse: true).
        });
      }
    } catch (e) {
      debugPrint('Chat Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    // Optimistic UI update could be done here
    try {
      final newMsg = await context.read<ChatRepository>().sendMessage(widget.taskId, text, user.id);
      if (newMsg != null && mounted) {
        setState(() {
          _messages.insert(0, newMsg); // Add to top (as listing is reverse)
        });
      }
    } catch (e) {
      debugPrint('Send Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle, style: GoogleFonts.outfit(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text('No messages yet', style: GoogleFonts.outfit(color: Colors.grey)))
                    : ListView.builder(
                        reverse: true, // Start from bottom
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMine ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isMine ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: msg.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.outfit(
                color: msg.isMine ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.formattedTime,
              style: GoogleFonts.outfit(
                color: msg.isMine ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, -1), blurRadius: 5)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: Color(0xFF1E3A8A), shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
