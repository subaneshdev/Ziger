import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/task_repository.dart';
import '../auth/auth_provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  // Local state
  String _status = 'open';
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    final userId = context.read<AuthProvider>().userProfile?.id;
    if (widget.task.assignedTo == userId && widget.task.assignedTo != null) {
       _status = 'assigned';
       if (widget.task.startedAt != null) _status = 'in_progress';
       if (widget.task.completedAt != null) _status = 'completed';
    }
  }

  Future<void> _applyForGig() async {
    setState(() => _isApplying = true);
    try {
      final user = context.read<AuthProvider>().userProfile;
      if (user == null) throw Exception('User not logged in');
      
      await context.read<TaskRepository>().applyForGig(widget.task.id, user.id);
      
      if (mounted) {
        setState(() {
          _status = 'applied'; // Update local state to show 'Applied'
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application Submitted! Waiting for approval.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _startGig() {
    // Navigate to Active Gig Screen
    context.push('/active-gig', extra: widget.task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            slivers: [
              // 1. Header Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.ios_share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1511578314322-379afb476865',
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay for text visibility if needed, or overlay content like the image
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Row(
                          children: [
                            _buildImageThumb('https://randomuser.me/api/portraits/thumb/men/1.jpg'),
                            const SizedBox(width: 8),
                             _buildImageThumb('https://randomuser.me/api/portraits/thumb/women/2.jpg'),
                            const SizedBox(width: 8),
                             _buildImageThumb('https://randomuser.me/api/portraits/thumb/men/3.jpg'),
                            const SizedBox(width: 8),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(
                                child: Text('+3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 2. Body Details
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0), // Pull up overlap
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14, color: AppColors.textSub),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.task.locationName,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text('4.9', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.task.companyName,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        children: [
                          _buildStatTag(Icons.check_circle, 'Active', Colors.green),
                          const SizedBox(width: 12),
                          _buildStatTag(Icons.remove_red_eye, '124 Views', Colors.blue),
                          const SizedBox(width: 12),
                          _buildStatTag(Icons.access_time_filled, 'Urgent', Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Job Details
                      const Text(
                        'Job Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We are looking for energetic individuals to help with the setup of a major tech conference. Tasks include arranging chairs, setting up signage, and assisting vendors with load-in. No prior experience required, but must be able to lift 25lbs. Read More',
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontSize: 15),
                      ),
                      const SizedBox(height: 32),

                      // Amenities
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAmenityCard(Icons.lunch_dining, 'Meal\nProvided'),
                          _buildAmenityCard(Icons.checkroom, 'Wear\nBlack'),
                          _buildAmenityCard(Icons.local_parking, 'Free\nParking'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Hiring Manager
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Alex Morgan',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Hiring Manager • ${widget.task.companyName}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, size: 20),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Sticky Bottom Bar
          Positioned(
            bottom: 30, // Floating slightly above bottom
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        '\$${widget.task.payout}', // Displaying payout as rate
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Per hour',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Action Button Logic wrapping UI
                  _buildStickyActionButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionButton(BuildContext context) {
    VoidCallback? onPressed;
    String label = 'Apply Now';
    Color bgColor = const Color(0xFFFFD700);
    Color textColor = Colors.black;

       switch (_status) {
      case 'open':
        onPressed = _isApplying ? null : _applyForGig;
        label = _isApplying ? 'Applying...' : 'Apply Now';
        break;
      case 'applied':
        onPressed = null;
        label = 'Applied (Waiting)';
        bgColor = Colors.grey.shade300;
        textColor = Colors.grey.shade600;
        break;
      case 'assigned':
        onPressed = _startGig;
        label = 'Start Gig';
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case 'in_progress':
        onPressed = _startGig; // Resume
        label = 'Resume Gig';
        bgColor = AppColors.secondary;
        break;
      case 'review':
        onPressed = null;
        label = 'Under Review';
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'completed':
        onPressed = null;
        label = 'Done';
        bgColor = AppColors.success;
        textColor = Colors.white;
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
             label,
             style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(IconData icon, String label) {
    return Container(
      width: 100, // Fixed width for uniform look
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.textMain),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumb(String url) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}

