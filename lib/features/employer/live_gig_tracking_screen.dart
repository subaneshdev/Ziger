import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task_model.dart';
import '../../core/theme.dart';
import '../../data/repositories/task_repository.dart';

class LiveGigTrackingScreen extends StatefulWidget {
  final Task task;
  const LiveGigTrackingScreen({super.key, required this.task});

  @override
  State<LiveGigTrackingScreen> createState() => _LiveGigTrackingScreenState();
}

class _LiveGigTrackingScreenState extends State<LiveGigTrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng _workerLocation;
  Set<Marker> _markers = {};
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Default to task location if live location not yet available
    _workerLocation = LatLng(
        widget.task.liveLat ?? widget.task.location.latitude,
        widget.task.liveLng ?? widget.task.location.longitude
    );
    _updateMarkers();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll for updates every 10 seconds (Simulated real-time)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
       // In a real app, use Supabase Realtime subscription instead of polling
       // Here we just fetch the latest task data
       // TODO: Implement fetchSingleTask in Repo or Realtime
       setState(() {
         // Simulate worker moving slightly for demo
         if (widget.task.status == 'in_progress') {
            _workerLocation = LatLng(
                _workerLocation.latitude + 0.0001, 
                _workerLocation.longitude + 0.0001
            );
            _updateMarkers();
            _moveCamera();
         }
       });
    });
  }

  void _updateMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('task_location'),
        position: widget.task.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.task.locationName),
      ),
      Marker(
        markerId: const MarkerId('worker_location'),
        position: _workerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Zigger (Live)'),
      ),
    };
  }

  Future<void> _moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_workerLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Transparent AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black), // Ensure visibility on map
      ),
      body: Stack(
        children: [
          // 1. Full Screen Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _workerLocation,
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
          ),

          // 2. Info Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    
                    // Worker Header
                    Row(
                      children: [
                         CircleAvatar(
                          radius: 24,
                          backgroundImage: widget.task.assignedWorkerAvatar != null 
                              ? NetworkImage(widget.task.assignedWorkerAvatar!)
                              : const NetworkImage('https://i.pravatar.cc/150?u=zigger'), 
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.task.assignedWorkerName ?? 'Assigned Worker', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Row(children: [Icon(Icons.star, size: 14, color: Colors.amber), Text(' 4.8 (12 gigs)')]),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: widget.task.status == 'in_progress' ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                              widget.task.status.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                  color: widget.task.status == 'in_progress' ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling Zigger...')));
                            }, 
                            icon: const Icon(Icons.call), label: const Text('Call'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Chat...')));
                            }, 
                            icon: const Icon(Icons.chat_bubble), 
                            label: const Text('Message'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, foregroundColor: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Live Updates & Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // Photo Feed
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          if (widget.task.checkInPhoto != null) _buildPhotoItem('Entry', widget.task.checkInPhoto!),
                          ...widget.task.inProgressPhotos.map((url) => _buildPhotoItem('Update', url)),
                          if (widget.task.checkOutPhoto != null) _buildPhotoItem('Exit', widget.task.checkOutPhoto!),
                          if (widget.task.checkInPhoto == null && widget.task.inProgressPhotos.isEmpty)
                            const Center(child: Text('No photos yet', style: TextStyle(color: Colors.grey))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String label, String url) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
