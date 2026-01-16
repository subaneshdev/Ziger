
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/worker/jobs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Browse Listings', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/worker/jobs'),
                      child: _buildQuickActionChip('All Jobs', Icons.work, isSelected: true),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.push('/worker/jobs'),
                      child: _buildQuickActionChip('Packers', Icons.inventory_2_outlined),
                    ),
                    // ... other chips linked similarly if needed, or just link All Jobs for now
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4.5 Recommended Section (AI)
              const Text(
                'Recommended for You ✨',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Task>>(
                future: context.read<TaskRepository>().getRecommendations(user?.id ?? ''),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                  final recs = snapshot.data!;
                  return SizedBox(
                    height: 280,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                         return SizedBox(
                           width: 260,
                           child: _buildGigCard(
                             context,
                             title: recs[index].title,
                             location: recs[index].locationName,
                             price: '\$${recs[index].payout}',
                             image: 'https://images.unsplash.com/photo-1542838132-92c53300491e',
                             isActive: true,
                             postedBy: recs[index].companyName,
                             task: recs[index],
                           ),
                         );
                      },
                    ),
                  );
                },
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
                  TextButton(
                    onPressed: () => context.push('/worker/jobs'),
                    child: const Text('See All', style: TextStyle(color: Colors.grey)),
                  ),
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
              
              const SizedBox(height: 80), // Bottom padding for FAB/Nav
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
             GestureDetector(onTap: () => context.push('/worker/jobs'), child: _buildNavItem(Icons.work_outline_rounded, false)),
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

  Widget _buildQuickActionChip(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontWeight: FontWeight.w600,
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
        } else {
             // Fallback or just ignore if no task
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
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.green, size: 8),
                          SizedBox(width: 6),
                          Text('Active Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                if (isInstant)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.blue, size: 16),
                          SizedBox(width: 4),
                          Text('Instant Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (rating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Footer (Applicants or Posted By)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (postedBy != null)
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026024d'),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Posted by $postedBy', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                if (isVerified)
                                  const Text('Verified Employer', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        )
                      else ...[
                        Row(
                          children: [
                           // Stacked avatars
                           SizedBox(
                             width: 40,
                             height: 24,
                             child: Stack(
                               children: [
                                 const Positioned(left: 0, child: CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12))),
                                 const Positioned(left: 14, child: CircleAvatar(radius: 10, backgroundColor: Colors.white, child: CircleAvatar(radius: 9, child: Icon(Icons.person_outline, size: 12)))),
                               ],
                             ),
                           ),
                           Text('+$applicants Applied recently', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                      
                      if (postedBy != null)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Apply'),
                        )
                      else
                        TextButton(
                          onPressed: () {},
                          child: const Text('Details', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
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
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.grey,
            size: 24,
          ),
        ),
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
    );
  }
}
