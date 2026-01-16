import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/task_repository.dart';
import '../../features/auth/auth_provider.dart';
import '../../models/task_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // For MVP, we list Tasks as "Chats".
  // Ideally, backend provides /api/my-conversations or similar.
  // We will reuse fetchTasksByEmployer (if employer) or fetchTasks (all) for now
  // or add a new endpoint fetchMyTasks(userId).
  
  // HACK: List "My Gigs" or "Assigned Gigs".
  List<Task> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    final repo = context.read<TaskRepository>();
    List<Task> result = [];

    try {
      if (user.role == 'employer') {
        result = await repo.fetchTasksByEmployer(user.id);
      } else {
        // For worker, we should ideally fetch "Assigned To Me"
        // Missing "fetchMyAssignedTasks" in Repo.
        // We will assume 'fetchTasks' returns open ones, not assigned ones.
        // Let's modify Repo to add `fetchTasksByWorker`.
        // For now, empty list or fetch all and filter client side? No, dangerous.
        // Fallback: Show empty/demo if worker for now until backend endpoint added.
        // Or re-purpose fetchTasksByEmployer if logic allows.
      }
      
      if (mounted) {
        setState(() {
          _chats = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Chat List Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No active conversations',
                        style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final task = _chats[index];
                    return Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Text(task.title[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(task.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tap to chat...', style: GoogleFonts.outfit(color: Colors.grey)),
                        onTap: () {
                          context.push('/chat', extra: {
                            'taskId': task.id,
                            'title': task.title,
                          });
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
