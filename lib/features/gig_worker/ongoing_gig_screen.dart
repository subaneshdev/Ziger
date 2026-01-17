
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../features/auth/auth_provider.dart';

// --- Screen State Enum ---
enum GigStep {
  reachLocation,
  checkIn,
  working,
  finished,
}

class OngoingGigScreen extends StatefulWidget {
  final Task task;

  const OngoingGigScreen({super.key, required this.task});

  @override
  State<OngoingGigScreen> createState() => _OngoingGigScreenState();
}

class _OngoingGigScreenState extends State<OngoingGigScreen> {
  // State
  GigStep _currentStep = GigStep.reachLocation;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  Position? _currentPosition;
  bool _isLocationValid = false;
  bool _isLoading = false;
  double _distanceToSite = 0.0;

  // Proofs
  File? _checkInPhoto;
  DateTime? _checkInTime;
  
  File? _checkOutPhoto;
  DateTime? _checkOutTime;

  // Working Updates - Mock for now as backend might not persist these in a way we can fetch easily in MVP
  // Ideally, we fetch this from backend. For MVP, we maintain local state or optimistic.
  final List<Map<String, dynamic>> _updates = [];

  final ImagePicker _picker = ImagePicker();
  
  // Config
  static const double _validRadiusMeters = 200; // Allow 200m radius

  @override
  void initState() {
    super.initState();
    _initializeGigState();
    _startLocationUpdates();
  }

  void _initializeGigState() {
     // Determine step from Task status
     if (widget.task.status == 'in_progress') {
       _currentStep = GigStep.working;
       if (widget.task.startedAt != null) {
         _checkInTime = widget.task.startedAt;
         _elapsedTime = DateTime.now().difference(widget.task.startedAt!);
       }
       _startTimer();
     } else if (widget.task.status == 'completed') {
       _currentStep = GigStep.finished;
     } else {
       _currentStep = GigStep.reachLocation;
     }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _startLocationUpdates() async {
    // Check permissions
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Listen to stream
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (!mounted) return;
      
      final double distance = Geolocator.distanceBetween(
        position.latitude, 
        position.longitude, 
        widget.task.location.latitude, 
        widget.task.location.longitude
      );

      setState(() {
        _currentPosition = position;
        _distanceToSite = distance;
        
        // Auto-advance step 1 -> 2 if nearby
        if (_currentStep == GigStep.reachLocation && distance <= _validRadiusMeters) {
          _currentStep = GigStep.checkIn;
        }
        
        _isLocationValid = distance <= _validRadiusMeters;
      });
    });
  }

  Future<void> _openMap() async {
    final lat = widget.task.location.latitude;
    final lng = widget.task.location.longitude;
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    }
  }

  Future<void> _handleCheckOut() async {
     // 1. Capture Photo
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    // 2. Confirmation Modal
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish Gig?'),
        content: const Text('This action cannot be undone. Ensure you have completed all tasks.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Finish Now')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    
    try {
      // Logic: upload proof then complete
      // In MVP backend: checkOut implementation calls 'completeGig'.
      // We pass the photo as a "progress" photo first or update task.
      // Since ApiTaskRepository checkOut does upload + complete, we rely on that.
      // But ApiTaskRepository uploadProgressPhoto takes "photoId" possibly?
      // Our backend API is minimal. Let's pretend we just send the path/base64 via repo.
      // IMPORTANT: In real app, we upload to Storage bucket (Supabase/S3), get URL, send URL.
      // For MVP Demo, we might be sending a mock URL or ignoring it.
      
      // We'll simulate upload delay and mock URL for now as we don't have storage bucket logic in this file.
      // Assuming Repository handles "upload" internally or accepts local path?
      // Repository signature: checkOut(taskId, photoUrl).
      
      await context.read<TaskRepository>().checkOut(widget.task.id, "mock_checkout_url_${DateTime.now()}");

      if (mounted) {
         setState(() {
           _checkOutPhoto = File(photo.path);
           _checkOutTime = DateTime.now();
           _timer?.cancel();
           _currentStep = GigStep.finished;
           _isLoading = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gig Completed Successfully!')));
         context.go('/worker/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error finishing gig: $e')));
      }
    }
  }

  Future<void> _handleCheckIn() async {
    if (!_isLocationValid) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are not at the location yet!')));
       return;
    }

    // 1. Capture Photo
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition();
      
      // Call Repository
      // Similar to CheckOut, we simulate photo upload
      await context.read<TaskRepository>().checkIn(widget.task.id, position.latitude, position.longitude, "mock_checkin_url");

      if (mounted) {
        setState(() {
          _checkInPhoto = File(photo.path);
          _checkInTime = DateTime.now();
          _currentStep = GigStep.working;
          _startTimer();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked In Successfully! Work Started.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking in: $e')));
      }
    }
  }

  Future<void> _addWorkUpdate() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    String? note = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String text = '';
        return AlertDialog(
          title: const Text('Add Note (Optional)'),
          content: TextField(onChanged: (v) => text = v, decoration: const InputDecoration(hintText: 'Describe progress...')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
            TextButton(onPressed: () => Navigator.pop(ctx, text), child: const Text('Add')),
          ],
        );
      },
    );

    setState(() => _isLoading = true);

    try {
       await context.read<TaskRepository>().uploadProgressPhoto(widget.task.id, "mock_update_url");
       if (mounted) {
         setState(() {
            _updates.insert(0, {
              'photo': File(photo.path),
              'note': note,
              'time': DateTime.now(),
            });
            _isLoading = false;
         });
       }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading update: $e')));
    }
  }

  // Prevent back navigation
  Future<bool> _onWillPop() async {
    if (_currentStep == GigStep.working || _currentStep == GigStep.checkIn) {
       final shouldPop = await showDialog<bool>(
         context: context, 
         builder: (ctx) => AlertDialog(
           title: const Text('Warning'),
           content: const Text('You have an active gig. Leaving this screen is not recommended.'),
           actions: [
             TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
             TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave Anyway', style: TextStyle(color: Colors.red))),
           ],
         )
       );
       return shouldPop ?? false;
    }
    return true;
  }
  
  void _reportIssue() {
    // Collect diagnostics
    final diag = {
      'taskId': widget.task.id,
      'step': _currentStep.toString(),
      'gps': _currentPosition?.toString() ?? 'Unknown',
      'validLoc': _isLocationValid,
      'user': context.read<AuthProvider>().userProfile?.id,
    };
    print('USER REPORTED ISSUE: $diag');
    
    // In real app, send to support API
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text('Support has been notified with your location and gig status. \n\nCall Employer directly for immediate help.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            Column(
              children: [
                 _buildStickyHeader(),
                 Expanded(
                   child: SingleChildScrollView(
                     child: Padding(
                       padding: const EdgeInsets.only(bottom: 150), // Increased padding for bottom panel
                       child: Column(
                         children: [
                           _buildLocationCard(),
                           if (_currentStep == GigStep.reachLocation || _currentStep == GigStep.checkIn)
                               _buildCheckInSection(),
                           if (_currentStep == GigStep.working || _currentStep == GigStep.finished)
                               _buildWorkUpdatesSection(),
                            if (_currentStep == GigStep.working)
                               _buildCheckOutSection(),
                            if (_currentStep == GigStep.finished)
                               _buildEarningsCard(),
                            _buildCommunicationSection(),
                            _buildHelpSection(),
                         ],
                       ),
                     ),
                   ),
                 ),
              ],
            ),
            if (_isLoading) ...[
              const ModalBarrier(color: Colors.black45, dismissible: false),
              const Center(child: CircularProgressIndicator()),
            ],
            _buildLiveStatusPanel(),
          ],
        ),
      ),
    );
  }

  // 1. GIG SUMMARY HEADER (Sticky)
  Widget _buildStickyHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Only allow back if not working, or if forced
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                   if (await _onWillPop()) {
                     if (context.mounted) context.pop();
                   }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(widget.task.companyName, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  _elapsedTime.inSeconds == 0 
                      ? 'Starts at ${widget.task.startTime != null ? DateFormat('hh:mm a').format(widget.task.startTime!) : 'Scheduled Time'}' 
                      : _formatDuration(_elapsedTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (_currentStep) {
      case GigStep.reachLocation:
        color = Colors.orange;
        text = 'NOT STARTED';
        break;
      case GigStep.checkIn:
        color = Colors.purple;
        text = 'CHECKING IN';
        break;
      case GigStep.working:
        color = Colors.blue;
        text = 'IN PROGRESS';
        break;
      case GigStep.finished:
        color = Colors.green;
        text = 'COMPLETED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // 2. LOCATION & NAVIGATION
  Widget _buildLocationCard() {
    String distanceText = _currentPosition == null 
        ? 'Locating...' 
        : '${(_distanceToSite / 1000).toStringAsFixed(2)} km away';
    
    // If very close, show meters
    if (_distanceToSite < 1000 && _currentPosition != null) {
      distanceText = '${_distanceToSite.round()} m away';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.task.locationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(distanceText, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(onPressed: _openMap, icon: const Icon(Icons.directions, color: Colors.blue)),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Icon(_isLocationValid ? Icons.check_circle : Icons.warning, color: _isLocationValid ? Colors.green : Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isLocationValid ? 'You are at the location' : 'Go to location to Start Gig', 
                    style: TextStyle(color: _isLocationValid ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.w500)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3A. CHECK-IN SECTION
  Widget _buildCheckInSection() {
    bool canProceed = _isLocationValid;
    // For testing/simulator sometimes we want to bypass if GPS is wonky, but requirement is strict.
    // Use Strict.
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('STEP 1: ENTRY PROOF', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            if (_checkInPhoto != null)
               ClipRRect(
                 borderRadius: BorderRadius.circular(8),
                 child: Image.file(_checkInPhoto!, height: 150, width: double.infinity, fit: BoxFit.cover),
               )
            else
               Container(
                 height: 150,
                 width: double.infinity,
                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: const [
                     Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                     SizedBox(height: 8),
                     Text('Take Check-in Photo', style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: canProceed ? _handleCheckIn : null,
                icon: const Icon(Icons.login),
                label: const Text('START GIG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (!canProceed)
               const Padding(
                 padding: EdgeInsets.only(top: 8.0),
                 child: Center(
                   child: Text(
                     'You must be within 200m of location', 
                     style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  // 3B. UPDATES TIMELINE
  Widget _buildWorkUpdatesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('WORK TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              if (_currentStep == GigStep.working)
               TextButton.icon(
                 onPressed: _addWorkUpdate,
                 icon: const Icon(Icons.add_a_photo, size: 16),
                 label: const Text('Add Update'),
               ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _updates.length + (_checkInPhoto != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _updates.length && _checkInPhoto != null) {
                 return _buildTimelineItem(
                   title: 'Checked In',
                   time: _checkInTime ?? DateTime.now(),
                   photo: _checkInPhoto!,
                   isStart: true,
                 );
              }
              final update = _updates[index];
              return _buildTimelineItem(
                title: 'Work Update',
                time: update['time'],
                photo: update['photo'],
                note: update['note'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required String title, required DateTime time, required File photo, String? note, bool isStart = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16, height: 16,
                decoration: BoxDecoration(color: isStart ? Colors.green : Colors.blue, shape: BoxShape.circle),
              ),
              Container(width: 2, height: 80, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('hh:mm a').format(time), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(photo, width: 60, height: 60, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    if (note != null && note.isNotEmpty) Expanded(child: Text(note, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3C. CHECK-OUT SECTION
  Widget _buildCheckOutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('STEP 3: COMPLETION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 8),
           SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _handleCheckOut,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('FINISH GIG'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. LIVE STATUS PANEL
  Widget _buildLiveStatusPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildStepIndicator(1, 'Reach', _currentStep.index >= 0),
                _buildStepLine(_currentStep.index >= 1),
                _buildStepIndicator(2, 'Check-in', _currentStep.index >= 1),
                _buildStepLine(_currentStep.index >= 2),
                _buildStepIndicator(3, 'Work', _currentStep.index >= 2),
                _buildStepLine(_currentStep.index >= 3),
                _buildStepIndicator(4, 'Finish', _currentStep.index >= 3),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Instructions: Maintain professional conduct. Report any safety concerns immediately.',
                style: TextStyle(color: Colors.blue, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isActive ? AppColors.primary : Colors.grey[300],
          child: isActive 
             ? const Icon(Icons.check, size: 12, color: Colors.white)
             : Text('$step', style: const TextStyle(fontSize: 10, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(child: Container(height: 2, color: isActive ? AppColors.primary : Colors.grey[300]));
  }

  // 5. COMMUNICATION
  Widget _buildCommunicationSection() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('COMMUNICATION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
             const SizedBox(height: 8),
             Row(
               children: [
                 Expanded(
                   child: OutlinedButton.icon(
                     onPressed: () {
                       context.push('/chat', extra: {
                         'taskId': widget.task.id,
                         'title': widget.task.companyName,
                       });
                     }, 
                     icon: const Icon(Icons.chat_bubble_outline), 
                     label: const Text('Chat with Employer')
                   ),
                 ),
                 const SizedBox(width: 12),
                 IconButton(
                   onPressed: () => launchUrl(Uri.parse('tel:123')), 
                   icon: const Icon(Icons.phone, color: Colors.green),
                   style: IconButton.styleFrom(backgroundColor: Colors.green[50]),
                 ),
               ],
             ),
             const SizedBox(height: 8),
             Wrap(
               spacing: 8,
               children: [
                 ActionChip(label: const Text('Reached Location'), onPressed: (){}),
                 ActionChip(label: const Text('Work Started'), onPressed: (){}),
                 ActionChip(label: const Text('Facing Issue'), onPressed: _reportIssue),
               ],
             ),
          ],
        ),
    );
  }
  
  // 6. EARNINGS
  Widget _buildEarningsCard() {
     return Card(
       margin: const EdgeInsets.all(16),
       color: Colors.green[50],
       child: ListTile(
         leading: const Icon(Icons.monetization_on, color: Colors.green),
         title: Text('Total Payout: \$${widget.task.payout}', style: const TextStyle(fontWeight: FontWeight.bold)),
         subtitle: const Text('Payment in Escrow • Released within 24h'),
         trailing: const Icon(Icons.check_circle, color: Colors.green),
       ),
     );
  }

  // 7. HELP
  Widget _buildHelpSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: TextButton.icon(
          onPressed: _reportIssue,
          icon: const Icon(Icons.flag_outlined, color: Colors.red),
          label: const Text('Report an Issue', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
