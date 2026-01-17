import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../models/task_model.dart';
import '../../data/repositories/task_repository.dart';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveGigScreen extends StatefulWidget {
  final Task task;
  const ActiveGigScreen({super.key, required this.task});

  @override
  State<ActiveGigScreen> createState() => _ActiveGigScreenState();
}

class _ActiveGigScreenState extends State<ActiveGigScreen> {
  late String _status;
  Timer? _timer;
  StreamSubscription<Position>? _locationSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status == 'assigned' ? 'assigned' : 
              widget.task.status == 'in_progress' ? 'in_progress' : 'review';
    
    if (_status == 'in_progress' && widget.task.startedAt != null) {
      _startTimer();
      _startLocationUpdates();
    }
  }

  void _startTimer() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() {});
      });
  }

  void _startLocationUpdates() {
    // Check permission first (assuming already granted if we are here, or prompt)
    // For simplicity, we just listen. In prod, handle permission denial.
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // Update every 20 meters
    );
    
    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      debugPrint('Location Update: ${position.latitude}, ${position.longitude}');
      context.read<TaskRepository>().updateLiveLocation(
        widget.task.id, 
        position.latitude, 
        position.longitude
      );
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _launchMaps() async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${widget.task.location.latitude},${widget.task.location.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isLoading = true);
    try {
      // 1. Verify Location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
            throw 'Location permissions are denied';
        }
      }
      
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        widget.task.location.latitude, widget.task.location.longitude
      );

      // Allow 500m radius (adjust as needed)
      if (distance > 500) {
        // Warning but allow for testing if needed, or block.
        // For production: throw 'You are too far from the gig location (${distance.toStringAsFixed(0)}m)';
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Warning: You are ${distance.toStringAsFixed(0)}m away.'))); 
      }

      // 2. Take Photo (Simulated/Real)
      // For MVP, we skip mandatory photo on check-in or use placeholder
      // await Future.delayed(const Duration(seconds: 1)); 
      
      // 3. Start Gig
      await context.read<TaskRepository>().startGig(widget.task.id);

      setState(() {
        _status = 'in_progress';
      });
      _startTimer();
      _startLocationUpdates();

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopLocationUpdates();
    super.dispose();
  }

  String _getFormattedDuration() {
    if (widget.task.startedAt == null) return "00:00:00";
    final duration = DateTime.now().difference(widget.task.startedAt!);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }



  Future<void> _handleComplete() async {
     setState(() => _isLoading = true);
    try {
      // Simulate completion
       await context.read<TaskRepository>().completeGig(widget.task.id);
       _stopLocationUpdates();
       
       if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gig Completed!')));
         context.pop(); // Go back
       }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUploadUpdate() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image == null) return;
    
    setState(() => _isLoading = true);
    try {
      // Placeholder for real upload
      String photoUrl = "https://via.placeholder.com/300?text=Progress+Update";
      
      await context.read<TaskRepository>().uploadProgressPhoto(widget.task.id, photoUrl);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update uploaded!')));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white, 
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.emergency, color: Colors.red), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Timer Card
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _status == 'in_progress' ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _status == 'assigned' ? 'Not Started' : _getFormattedDuration(),
                    style: GoogleFonts.spaceMono(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _status == 'in_progress' ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status == 'in_progress' ? 'ON CLOCK' : 'READY',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            if (_status == 'in_progress')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Update',
                    onTap: _handleUploadUpdate,
                    color: Colors.blue,
                  ),
                  _buildActionButton(
                    icon: Icons.chat,
                    label: 'Chat',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat opening... (Placeholder)')));
                    },
                    color: Colors.orange,
                  ),
                ],
              ),
            
            const Spacer(),
            
            // Info
             ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              subtitle: Text(widget.task.locationName),
              trailing: IconButton(
                icon: const Icon(Icons.directions, color: Colors.blue),
                onPressed: _launchMaps,
              ),
            ),
            const Divider(),
            
            const Spacer(),
            
            // Action Button
            if (_status == 'assigned')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCheckIn,
                  icon: const Icon(Icons.play_arrow),
                  label: _isLoading ? const CircularProgressIndicator() : const Text('START GIG'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              )
            else if (_status == 'in_progress')
                 SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleComplete,
                  icon: const Icon(Icons.stop),
                  label: _isLoading ? const CircularProgressIndicator() : const Text('FINISH GIG'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
