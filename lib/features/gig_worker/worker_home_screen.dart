
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/task_model.dart';
import '../auth/auth_provider.dart';

class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().userProfile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar
              Row(
                children: [
                   Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search gigs nearby...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildIconButton(Icons.tune),
                  const SizedBox(width: 12),
                  _buildIconButton(Icons.notifications_outlined, hasDot: true),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Greeting
              Text(
                'Hi, Gig Hunter! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready to earn some extra cash today?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSub,
                    ),
              ),
              const SizedBox(height: 24),

              // --- NEW: Ongoing Gig Banner ---
              // Ideally this is conditional, but for now we show it to allow navigation
              GestureDetector(
                onTap: () {
                   // Navigate to the separate route
                   context.push('/worker/ongoing-gig');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: const Icon(Icons.timelapse, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ongoing Gig Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Retail Store Assistant', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              // --------------------------------

              // 3. Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Deep Blue Banner
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage('https://img.freepik.com/free-vector/gradient-dynamic-blue-lines-background_23-2148995756.jpg'), // Placeholder or asset
                     fit: BoxFit.cover,
                     opacity: 0.3, 
                  )
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'New!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Find your next\nbig gig!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),


              // 5. Popular Gigs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Gigs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // 'See All' removed
                ],
              ),
              const SizedBox(height: 12),
              
              // Gig List Items
              FutureBuilder<List<Task>>(
                future: context.read<TaskRepository>().fetchTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load gigs.'));
                  }
                  final tasks = snapshot.data ?? [];
                  
                  if (tasks.isEmpty) {
                     return const Center(
                       child: Padding(
                         padding: EdgeInsets.all(20.0),
                         child: Text('No gigs available right now.', style: TextStyle(color: Colors.grey)),
                       ),
                     );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildGigCard(
                        context,
                        title: task.title,
                        location: task.locationName,
                        price: '\$${task.payout}',
                        image: 'https://images.unsplash.com/photo-1542838132-92c53300491e', // Placeholder image until Task has one
                        isActive: task.status == 'open',
                        postedBy: task.companyName,
                        task: task,
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
           color: Colors.white,
           borderRadius: BorderRadius.circular(32),
           boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
           ],
         ),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             _buildNavItem(Icons.home_rounded, true),
             _buildNavItem(Icons.work_outline_rounded, false),
             GestureDetector(onTap: () => context.push('/chats'), child: _buildNavItem(Icons.chat_bubble_outline_rounded, false, hasDot: true)),
             GestureDetector(
               onTap: () => context.push('/worker/profile'),
               child: _buildNavItem(Icons.person_outline_rounded, false),
             ),
           ],
         ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {bool hasDot = false}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: Colors.black87),
          if (hasDot)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildGigCard(
    BuildContext context, {
    required String title,
    required String location,
    required String price,
    String? rating,
    required String image,
    bool isActive = false,
    bool isInstant = false,
    int? applicants,
    String? postedBy,
    bool isVerified = false,
    Task? task,
  }) {
    return GestureDetector(
      onTap: () {
        if (task != null) {
          context.push('/worker/task-details', extra: task);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(image, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(12)),
                    child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, {bool hasDot = false}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFD700) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.black : Colors.grey, size: 24),
        ),
        if (hasDot)
          Positioned(
            top: 12, right: 12,
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
          ),
      ],
    );
  }
}
