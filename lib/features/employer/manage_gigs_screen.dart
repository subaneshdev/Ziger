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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                task.categoryImageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey.shade400)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Applications',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
             Expanded(
               child: FutureBuilder<List<dynamic>>(
                  future: context.read<TaskRepository>().getApplications(taskId),
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                     }
                     if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                     }
                     final apps = snapshot.data ?? [];
                     if (apps.isEmpty) {
                        return const Center(child: Text('No applications yet', style: TextStyle(color: Colors.black, fontSize: 16)));
                     }
                     
                     return ListView.builder(
                       itemCount: apps.length,
                       itemBuilder: (context, index) {
                         final app = apps[index];
                         return Container(
                           margin: const EdgeInsets.only(bottom: 16),
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.grey.shade50,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.grey.shade200),
                           ),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   CircleAvatar(
                                     backgroundColor: Colors.blue.shade100,
                                     child: const Icon(Icons.person, color: Colors.blue),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       app.worker.fullName ?? 'Worker',
                                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 app.pitchMessage ?? 'No message',
                                 style: const TextStyle(color: Colors.black87),
                               ),
                               const SizedBox(height: 12),
                               Row(
                                 children: [
                                   Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            // Show loading indicator or disable button? For now just await
                                            // Ideally we should have isHiring state but local var is hard in ListView builder
                                            await context.read<TaskRepository>().assignWorker(taskId, app.worker.id);
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Worker hired successfully! You can now chat with them from the Chats tab.'),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(seconds: 4),
                                                ),
                                              );
                                              _loadTasks();
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              debugPrint('Hire Error: $e');
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error hiring: $e')));
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                                        child: const Text('Hire', style: TextStyle(color: Colors.white)),
                                      ),
                                   )
                                 ],
                               )
                             ],
                           ),
                         );
                       },
                     );
                  },
               ),
            ),
          ],
        ),
      ),
    );
  }
}

