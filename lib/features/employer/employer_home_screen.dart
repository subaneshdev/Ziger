import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/task_model.dart';

class EmployerHomeScreen extends StatelessWidget {
  const EmployerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userProfile;

    // Loading State
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty)
                            ? NetworkImage(user!.profilePhotoUrl!)
                            : null,
                        backgroundColor: Colors.grey.shade200,
                        child: (user?.profilePhotoUrl == null || user!.profilePhotoUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            user?.fullName ?? 'Employer',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // KYC Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user?.kycStatus == 'approved' ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                         color: user?.kycStatus == 'approved' ? Colors.green : Colors.orange
                      ),
                    ),
                    child: Text(
                      user?.kycStatus == 'approved' ? 'Verified' : 'Pending',
                      style: GoogleFonts.outfit(
                        color: user?.kycStatus == 'approved' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 2. Wallet Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$${user?.walletBalance.toStringAsFixed(2) ?? "0.00"}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                               // Add Funds Action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Add Money'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                               // Withdraw Action
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Withdraw'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 3. Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildQuickActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Post New Gig',
                    color: Colors.orange,
                    onTap: () {
                       context.push('/employer/create-gig');
                    },
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildQuickActionCard(
                    icon: Icons.list_alt,
                    label: 'Manage Gigs',
                    color: Colors.blue,
                    onTap: () {
                       context.push('/employer/manage-gigs');
                    },
                  )),
                ],
              ),
              
              const SizedBox(height: 24),

              // 4. Active Gigs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Gigs',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/employer/manage-gigs'),
                    child: Text('See All', style: GoogleFonts.outfit(color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              FutureBuilder<List<Task>>(
                future: context.read<TaskRepository>().fetchTasksByEmployer(user?.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Error loading gigs: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    );
                  }
                  
                  final tasks = snapshot.data ?? [];
                  if (tasks.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No active gigs',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'Post your first gig to get started!',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.work_outline, color: Colors.blue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${task.status.toUpperCase()} • ${task.locationName}',
                                    style: GoogleFonts.outfit(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${task.payout}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
         margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
         decoration: BoxDecoration(
           color: Colors.black,
           borderRadius: BorderRadius.circular(32),
           boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5)),
           ],
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             IconButton(icon: const Icon(Icons.home_filled, color: Colors.white), onPressed: () {}), // Current
             IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white54), onPressed: () => context.push('/employer/create-gig')),
             IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white54), onPressed: () => context.push('/chats')),
             IconButton(icon: const Icon(Icons.person_outline, color: Colors.white54), onPressed: () => context.push('/employer/profile')),
           ],
         ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
