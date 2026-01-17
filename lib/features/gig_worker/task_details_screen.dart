import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/task_repository.dart';
import '../auth/auth_provider.dart';
import '../../core/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
        // Strip "Exception: " prefix if present from ApiService
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             content: Text(message),
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }



  Future<void> _openMap() async {
    final lat = widget.task.location.latitude;
    final lng = widget.task.location.longitude;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch map url');
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
      body: CustomScrollView(
        slivers: [
          // 1. Header Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   _buildCategoryHeaderImage(widget.task.category),
                   // Gradient for text readability if needed
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                       ),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Company
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.business, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.task.companyName,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF6B7280),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.task.locationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Price Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '\$${widget.task.payout}',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                              Text(
                                widget.task.paymentType == 'hourly' ? '/ hr' : 'Fixed',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Quick Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDetailItem(Icons.calendar_today, 'Date', _formatDate(widget.task.startTime)),
                        _buildDetailItem(Icons.access_time, 'Time', _formatTimeRange(widget.task.startTime, widget.task.endTime)),
                        _buildDetailItem(Icons.timer_outlined, 'Duration', '${widget.task.time} Hours'),
                        _buildDetailItem(Icons.people_outline, 'Openings', '${widget.task.workersRequired} Worker(s)'),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Description
                    Text(
                      'About the Gig',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.task.description.isNotEmpty 
                          ? widget.task.description 
                          : 'No detailed description provided by the employer.',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        height: 1.6,
                        color: const Color(0xFF4B5563),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Requirements (Dynamic)
                    if (widget.task.requirements.isNotEmpty || widget.task.proofRequired.isNotEmpty) ...[
                      Text(
                        'Requirements & Amenities',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                           // Render Proof Requirements
                           ...widget.task.proofRequired.map((req) => _buildRequirementChip(req, isProof: true)),
                           // Render General Requirements (assuming map keys are the reqs)
                           ...widget.task.requirements.entries.map((e) {
                             if (e.value == true) return _buildRequirementChip(e.key);
                             return const SizedBox.shrink(); // Skip false/null
                           }).whereType<Widget>(),
                           if (widget.task.requirements.isEmpty && widget.task.proofRequired.isEmpty) 
                              const Text('No specific requirements listed.')
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Location Map
                    Text(
                      'Location',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(target: widget.task.location, zoom: 14),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('gigLocation'),
                                  position: widget.task.location,
                                )
                              },
                              zoomControlsEnabled: false,
                              liteModeEnabled: true,
                              onTap: (_) => _openMap(),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: FloatingActionButton.small(
                                onPressed: _openMap,
                                backgroundColor: Colors.white,
                                child: const Icon(Icons.directions, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Hiring Manager
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: (widget.task.assignedWorkerAvatar != null &&
                                    widget.task.assignedWorkerAvatar!.isNotEmpty &&
                                    widget.task.assignedWorkerAvatar!.startsWith('http'))
                                ? NetworkImage(widget.task.assignedWorkerAvatar!)
                                : const NetworkImage('https://ui-avatars.com/api/?name=Hiring+Manager'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hiring Manager', // We don't have manager name in Task model yet, just company
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  widget.task.companyName,
                                  style: GoogleFonts.outfit(
                                    color: Colors.grey.shade600, 
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _buildSimpleActionButton(context),
        ),
      ),
    );
  }

  Widget _buildCategoryHeaderImage(String category) {
     String imageUrl;
     switch (category.toLowerCase()) {
      case 'catering': imageUrl = 'https://images.unsplash.com/photo-1555244162-803834f70033'; break;
      case 'logistics': imageUrl = 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d'; break;
      case 'retail': imageUrl = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8'; break;
      case 'cleaning': imageUrl = 'https://images.unsplash.com/photo-1581578731117-10452966116a'; break;
      case 'events': imageUrl = 'https://images.unsplash.com/photo-1511578314322-379afb476865'; break;
      default: imageUrl = 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab';
    }
    return Image.network(imageUrl, fit: BoxFit.cover);
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRequirementChip(String label, {bool isProof = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isProof ? const Color(0xFFFFF7ED) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isProof ? const Color(0xFFFFEDD5) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProof ? Icons.camera_alt_outlined : Icons.check_circle_outline,
            size: 16,
            color: isProof ? const Color(0xFFC2410C) : const Color(0xFF4B5563),
          ),
          const SizedBox(width: 8),
          Text(
            label, // e.g., "Wear Black" or "Selfie Required"
            style: GoogleFonts.outfit(
              color: isProof ? const Color(0xFF9A3412) : const Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionButton(BuildContext context) {
    VoidCallback? onPressed;
    String label = 'Apply Now';
    Color bgColor = const Color(0xFFFFD700);
    Color textColor = Colors.black;

    final user = context.watch<AuthProvider>().userProfile;
    final isWorker = user?.role == 'worker';
    // If not logged in, we let them click but maybe redirect to login (or show error) - preserving existing flow but validating role
    // If logged in and NOT worker, disable.
    
    // Status Logic
    switch (_status) {
      case 'open':
        if (user != null && !isWorker) {
             onPressed = null;
             label = 'Workers Only';
             bgColor = Colors.grey.shade300;
             textColor = Colors.grey.shade600;
        } else {
             onPressed = _isApplying ? null : _applyForGig;
             label = _isApplying ? 'Applying...' : 'Apply Now';
        }
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

    return SizedBox(
      width: double.infinity,
      height: 56, // Tall button
      child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
        child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return 'Flexible';
    return DateFormat('MMM d, y').format(date.toLocal());
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null) return 'Flexible';
    final s = DateFormat('jm').format(start.toLocal());
    if (end != null) {
      final e = DateFormat('jm').format(end.toLocal());
      return '$s - $e';
    }
    return s;
  }
}
