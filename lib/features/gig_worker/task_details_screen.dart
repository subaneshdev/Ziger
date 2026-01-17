import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // Added for ImageFilter.blur
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
    } else {
       _checkApplicationStatus();
    }
  }

  Future<void> _checkApplicationStatus() async {
    try {
       final application = await context.read<TaskRepository>().getMyApplication(widget.task.id);
       if (application != null && mounted) {
           setState(() => _status = 'applied');
       }
    } catch (e) {
       debugPrint('Error checking status: $e');
    }
  }

  Future<void> _applyForGig() async {
    setState(() => _isApplying = true);
    try {
      final user = context.read<AuthProvider>().userProfile;
      if (user == null) throw Exception('User not logged in');
      
      await context.read<TaskRepository>().applyForGig(widget.task.id, user.id);
      
      if (mounted) {
        setState(() => _status = 'applied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application Submitted! Waiting for approval.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _startGig() => context.push('/active-gig', extra: widget.task);

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'catering': return 'https://images.unsplash.com/photo-1555244162-803834f70033';
      case 'logistics': return 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d';
      case 'retail': return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8';
      case 'cleaning': return 'https://images.unsplash.com/photo-1581578731117-10452966116a';
      case 'events': return 'https://images.unsplash.com/photo-1511578314322-379afb476865';
      default: return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab'; // General
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Date Formatting (Simple manual formatting to avoid intl dependency if not added)
    final date = widget.task.startTime ?? DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final monthStr = months[date.month - 1];
    final dayStr = date.day.toString();
    final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- 1. Hero Image (Luma Style) ---
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glassmorphism
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _getCategoryImage(widget.task.category),
                        fit: BoxFit.cover,
                      ),
                      // Gradient for readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. Content Body ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Block & Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Calendar Block
                          Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(monthStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                Text(dayStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.grey.shade200,
                                      child: const Icon(Icons.business, size: 12, color: Colors.black),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Hosted by ${widget.task.companyName}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const SizedBox(height: 32),

                      // Location & Time
                      _buildInfoRow(Icons.location_on_outlined, widget.task.locationName, 'View on Map'),
                      const SizedBox(height: 24),
                      _buildInfoRow(Icons.access_time, '$timeStr • ${widget.task.time} Hours Estimate', 'Add to Calendar'),
                      
                      const SizedBox(height: 32),
                      
                      // About Section
                      const Text('About Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        widget.task.description.isNotEmpty ? widget.task.description : "No description provided.",
                        style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800),
                      ),
                      
                      const SizedBox(height: 32),

                      // Amenities / Requirements Grid
                      if (widget.task.requirements.isNotEmpty) ...[
                        const Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (widget.task.requirements['gloves_mask'] == 'Yes') _buildChip(Icons.masks, 'Mask Required'),
                            if (widget.task.requirements['dress_code'] != null && widget.task.requirements['dress_code'].toString().isNotEmpty)
                               _buildChip(Icons.checkroom, widget.task.requirements['dress_code']),
                             _buildChip(Icons.group, '${widget.task.workersRequired} Workers Needed'),
                             _buildChip(Icons.verified_user, 'ID Verification'),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                      
                      // Map Placeholder (Static for MVP)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network('https://maps.googleapis.com/maps/api/staticmap?center=${widget.task.location.latitude},${widget.task.location.longitude}&zoom=14&size=600x300&key=YOUR_API_KEY', 
                                errorBuilder: (c,e,s) => const Center(child: Icon(Icons.map, color: Colors.grey)),
                                fit: BoxFit.cover,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                                  child: const Text('Get Directions', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),


                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- 3. Persistent Bottom Bar ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('TOTAL PAYOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text('\$${widget.task.payout}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  Expanded(flex: 2, child: _buildStickyActionButton(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, String actionText) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 24, color: Colors.black),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 2),
              Text(actionText, style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStickyActionButton(BuildContext context) {
    VoidCallback? onPressed;
    String label = 'Apply Now';
    Color bgColor = Colors.black; // Luma style black button
    Color textColor = Colors.white;

    switch (_status) {
      case 'open':
        onPressed = _isApplying ? null : _applyForGig;
        label = _isApplying ? 'Applying...' : 'Apply to Join';
        break;
      case 'applied':
        onPressed = null;
        label = 'Applied';
        bgColor = Colors.grey.shade300;
        textColor = Colors.grey.shade600;
        break;
      case 'assigned':
        onPressed = _startGig;
        label = 'Start Gig';
        bgColor = AppColors.primary;
        break;
      case 'in_progress':
        onPressed = _startGig; 
        label = 'Resume';
        bgColor = AppColors.secondary;
        break;
      case 'completed':
        onPressed = null;
        label = 'Completed';
        bgColor = Colors.green;
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
