import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/task_model.dart';
import '../auth/auth_provider.dart';

class EmployerManageGigsScreen extends StatefulWidget {
  const EmployerManageGigsScreen({super.key});

  @override
  State<EmployerManageGigsScreen> createState() => _EmployerManageGigsScreenState();
}

class _EmployerManageGigsScreenState extends State<EmployerManageGigsScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.userProfile;
      if (user != null) {
        final tasks = await context.read<TaskRepository>().fetchTasksByEmployer(user.id);
        if (mounted) {
           setState(() {
             _tasks = tasks;
             _isLoading = false;
           });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Gigs',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tasks.isEmpty
                ? Center(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                         const Icon(Icons.list_alt, size: 64, color: Colors.grey),
                         const SizedBox(height: 16),
                         Text('No gigs posted yet.', style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: task.status == 'open' ? Colors.green.shade50 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    task.status.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: task.status == 'open' ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Location: ${task.locationName}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                            Text('Pay: \$${task.payout} (${task.paymentType})', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Edit Logic later
                            },
                             child: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                         Expanded(
                           child: task.status == 'in_progress' 
                           ? ElevatedButton.icon(
                               onPressed: () {
                                 context.push('/live-gig-tracking', extra: task);
                               },
                               icon: const Icon(Icons.location_on, size: 16, color: Colors.white),
                               label: const Text('Track Live', style: TextStyle(color: Colors.white)),
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                             )
                           : ElevatedButton(
                               onPressed: () {
                                 _showApplicationsDialog(context, task.id);
                               },
                               style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                               child: const Text('Applications (1)', style: TextStyle(color: Colors.white)),
                             ),
                         ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
      ),
    );
  }
  void _showApplicationsDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Applications'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>( // Using dynamic to avoid circular dep if types not ready, but better use TaskApplication
            future: context.read<TaskRepository>().getApplications(taskId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final apps = snapshot.data ?? [];
              if (apps.isEmpty) {
                return const Text('No applications yet.');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index]; 
                  // Assuming app is TaskApplication, but allowing for dynamic if needed
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(app.worker.profilePictureUrl ?? ''),
                      child: app.worker.profilePictureUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(app.worker.fullName),
                    subtitle: Text(app.pitchMessage ?? 'No message'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        try {
                           await context.read<TaskRepository>().assignWorker(taskId, app.worker.id);
                           if (context.mounted) {
                             Navigator.pop(context);
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Worker Assigned!')));
                             _loadTasks(); // Refresh list to show "Assigned/In Progress" status or button change
                           }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      child: const Text('Assign'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

