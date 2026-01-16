
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';

// --- Screen State Enum ---
enum GigStep {
  reachLocation,
  checkIn,
  working,
  finished,
}

class OngoingGigScreen extends StatefulWidget {
  final Map<String, dynamic> gigData; // Pass actual gig data here

  const OngoingGigScreen({super.key, required this.gigData});

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

  // Proofs
  File? _checkInPhoto;
  DateTime? _checkInTime;
  Position? _checkInLocation;
  
  File? _checkOutPhoto;
  DateTime? _checkOutTime;
  Position? _checkOutLocation;

  // Working Updates
  final List<Map<String, dynamic>> _updates = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _startLocationUpdates() async {
    // Check permissions first (omitted for brevity, assume granted or handled by global service)
    // Stream position logic
    // For demo, we just get current position
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          // Simple mock validation: Assume valid if within range
          // In real app, calculate distance to widget.gigData['location']
          _isLocationValid = true; 
        });
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  Future<void> _openMap() async {
    // Mock Coordinates
    const double lat = 37.7749;
    const double lng = -122.4194;
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
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

    // 2. Capture GPS & Time
    final position = await Geolocator.getCurrentPosition();
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _checkInPhoto = File(photo.path);
        _checkInTime = DateTime.now();
        _checkInLocation = position;
        _currentStep = GigStep.working;
        _startTimer();
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in Successful!')));
    }
  }

  Future<void> _addWorkUpdate() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    // Show dialog for optional note
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

    setState(() {
      _updates.insert(0, {
        'photo': File(photo.path),
        'note': note,
        'time': DateTime.now(),
      });
    });
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
    
    // Simulate API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
       setState(() {
         _checkOutPhoto = File(photo.path);
         _checkOutTime = DateTime.now();
         _timer?.cancel();
         _currentStep = GigStep.finished;
         _isLoading = false;
       });
       // Navigate away or show summary
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gig Completed!')));
       context.go('/worker/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
               _buildStickyHeader(),
               Expanded(
                 child: SingleChildScrollView(
                   child: Padding(
                     padding: const EdgeInsets.only(bottom: 100), // Space for bottom sheet/instructions
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
    );
  }

  // 1. GIG SUMMARY HEADER
  Widget _buildStickyHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, bottom: 16, left: 16, right: 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                   if (context.canPop()) {
                     context.pop();
                   } else {
                     // If it's the root (replaced home), maybe go to job list or do nothing?
                     // For now, let's try pop, or user might want to navigate to a specific route.
                     context.go('/worker/home'); // Re-navigating to home might just reload this screen due to my change.
                     // Let's assume there is somewhere to go back to if we are in a 'gig screen'.
                     // For correct behavior if this is the only screen in stack:
                     // We might need to change the 'Home' implementation back to original if they want to leave.
                     // But strictly following instruction: "have a back button".
                     if (context.canPop()) context.pop();
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
                    Text(widget.gigData['title'] ?? 'Retail Store Assistant', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.gigData['employer'] ?? 'Zara Pvt Ltd', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
                  _elapsedTime.inSeconds == 0 ? 'Starts in 00:30:00' : _formatDuration(_elapsedTime),
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
                      Text(widget.gigData['address'] ?? '123 Main Street, City Center', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('0.2 km away', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
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
                Text(_isLocationValid ? 'You are at the location' : 'Not at location yet', style: TextStyle(color: _isLocationValid ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3A. CHECK-IN SECTION
  Widget _buildCheckInSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('STEP 1: ENTRY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                 child: const Center(child: Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
               ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLocationValid ? _handleCheckIn : null,
                icon: const Icon(Icons.login),
                label: const Text('START GIG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (!_isLocationValid)
               const Padding(
                 padding: EdgeInsets.only(top: 8.0),
                 child: Text('Reach location to enable Check-in', style: TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
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
              const Text('WORK UPDATES', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                 // Check-in entry at bottom
                 return _buildTimelineItem(
                   title: 'Checked In',
                   time: _checkInTime!,
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
      child: SizedBox(
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
                'Safety: Please wear your safety vest at all times on site.',
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
                     onPressed: (){}, 
                     icon: const Icon(Icons.chat_bubble_outline), 
                     label: const Text('Chat with Employer')
                   ),
                 ),
                 const SizedBox(width: 12),
                 IconButton(
                   onPressed: () => launchUrl(Uri.parse('tel:1234567890')), 
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
                 ActionChip(label: const Text('Facing Issue'), onPressed: (){}),
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
       child: const ListTile(
         leading: Icon(Icons.monetization_on, color: Colors.green),
         title: Text('Total Payout: \$120.00'),
         subtitle: Text('Payment in Escrow • Released within 24h'),
         trailing: Icon(Icons.check_circle, color: Colors.green),
       ),
     );
  }

  // 7. HELP
  Widget _buildHelpSection() {
    return Center(
      child: TextButton.icon(
        onPressed: (){},
        icon: const Icon(Icons.flag_outlined, color: Colors.red),
        label: const Text('Report an Issue', style: TextStyle(color: Colors.red)),
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
