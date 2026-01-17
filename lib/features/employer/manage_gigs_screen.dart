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
                            // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                             // Edit Logic
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Edit', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: task.status == 'in_progress'
                        ? ElevatedButton(
                          onPressed: () {
                             // Navigate to Live Tracking
                             context.push('/live-gig-tracking', extra: task);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Track Live', style: TextStyle(color: Colors.white)),
                        )
                        : (task.status == 'assigned')
                           ? ElevatedButton(
                              onPressed: null, // Disabled
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text('Waiting for Start', style: TextStyle(color: Colors.black54)),
                           )
                           : ElevatedButton(
                              onPressed: () => _showApplicationsDialog(context, task.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Text('Applications (${task.applicationCount ?? 0})', style: const TextStyle(color: Colors.white)),
                            ),
                      ),
                    ],
                  ),
                  ],
                ),
              );
            },
          ),
      ),
    );
  }
  void _showApplicationsDialog(BuildContext context, String taskId) {
    print('DEBUG: Opening Applications Dialog for $taskId');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Applications', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<dynamic>>(
            future: context.read<TaskRepository>().getApplications(taskId),
            builder: (context, snapshot) {
              print('DEBUG: Snapshot: ${snapshot.connectionState}, Error: ${snapshot.error}, DataLen: ${snapshot.data?.length}');
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', 
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              
              final apps = snapshot.data ?? [];
              
              if (apps.isEmpty) {
                return const Center(
                  child: Text('No applications found.', style: TextStyle(color: Colors.black, fontSize: 16)),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: apps.map((app) {
                     var workerName = 'Unknown';
                     String? photoUrl;
                     String pitch = 'No message';
                     
                     try {
                        // Safe extraction for both Map and Object
                        dynamic worker = (app is Map) ? app['worker'] : (app as dynamic).worker;
                        if (worker is Map) {
                          workerName = worker['full_name'] ?? 'Unknown';
                          photoUrl = worker['profile_photo_url'];
                        } else {
                          workerName = worker?.fullName ?? 'Unknown';
                          photoUrl = worker?.profilePhotoUrl;
                        }
                        
                        pitch = (app is Map) ? app['pitch_message'] : (app as dynamic).pitchMessage;
                        pitch ??= 'No message';
                     } catch (e) {
                       print('DEBUG: Parse Error: $e');
                     }

                     return Card(
                       color: Colors.white,
                       elevation: 2,
                       margin: const EdgeInsets.only(bottom: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       child: Padding(
                         padding: const EdgeInsets.all(12),
                         child: Row(
                           children: [
                             CircleAvatar(
                               radius: 24,
                               backgroundImage: (photoUrl != null && photoUrl.startsWith('http')) 
                                 ? NetworkImage(photoUrl) 
                                 : null,
                               backgroundColor: Colors.grey.shade200,
                               child: (photoUrl == null || !photoUrl.startsWith('http')) 
                                 ? const Icon(Icons.person, color: Colors.grey) 
                                 : null,
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(
                                     workerName,
                                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     pitch,
                                     maxLines: 2, 
                                     overflow: TextOverflow.ellipsis,
                                     style: const TextStyle(color: Colors.black87, fontSize: 13),
                                   ),
                                 ],
                               ),
                             ),
                             ElevatedButton(
                               onPressed: () async {
                                 try {
                                   String workerId;
                                    try {
                                       // Extract Worker ID robustly
                                      dynamic worker = (app is Map) ? app['worker'] : (app as dynamic).worker;
                                      if (worker is Map) {
                                        workerId = worker['id'] ?? worker['user_id'];
                                      } else {
                                         workerId = worker.id;
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error finding worker ID: $e')),
                                      );
                                      return;
                                    }
                                    
                                   print('DEBUG: Assigning Worker $workerId to Task $taskId');
                                   
                                   // Call Repository
                                   await context.read<TaskRepository>().assignWorker(taskId, workerId);
                                   
                                   if (context.mounted) {
                                      Navigator.pop(context); // Close dialog
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Assigned $workerName successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _loadTasks(); // Refresh list to update UI
                                   }
                                 } catch (e) {
                                   if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Assign Failed: $e'), backgroundColor: Colors.red),
                                      );
                                   }
                                 }
                               },
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.black,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 minimumSize: const Size(60, 36),
                               ),
                               child: const Text('Assign', style: TextStyle(fontSize: 12)),
                             ),
                           ],
                         ),
                       ),
                     );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

