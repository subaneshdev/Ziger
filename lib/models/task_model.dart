import 'package:google_maps_flutter/google_maps_flutter.dart';

class Task {
  final String id;
  final String employerId; // Maps to created_by
  final String title;
  final String companyName;
  final String locationName;
  final LatLng location;
  final double payout;
  final String distance;
  final String time; // Maps to estimated_hours
  final String status;
  
  // New Fields
  final String description;
  final int workersRequired;
  final String paymentType; // 'fixed', 'hourly'
  final DateTime? startTime;
  final DateTime? endTime;
  final String category;
  final Map<String, dynamic> requirements; // JSONB
  final List<String> proofRequired;
  
  // Lifecycle Fields
  final String? assignedTo;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final double? liveLat;
  final double? liveLng;
  final DateTime? lastUpdated;
  final List<String> inProgressPhotos;
  final String? assignedWorkerName;
  final String? assignedWorkerAvatar;

  Task({
    required this.id,
    required this.employerId,
    required this.title,
    required this.companyName,
    required this.locationName,
    required this.location,
    required this.payout,
    required this.distance,
    required this.time,
    required this.status,
    this.description = '',
    this.workersRequired = 1,
    this.paymentType = 'fixed',
    this.startTime,
    this.endTime,
    this.category = 'general',
    this.requirements = const {},
    this.proofRequired = const [],
    this.assignedTo,
    this.startedAt,
    this.completedAt,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.liveLat,
    this.liveLng,
    this.lastUpdated,
    this.inProgressPhotos = const [],
    this.assignedWorkerName,
    this.assignedWorkerAvatar,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    String employerId = '';
    if (json['created_by'] is Map) {
      employerId = json['created_by']['id'] ?? '';
    } else if (json['created_by'] is String) {
      employerId = json['created_by'];
    }

    return Task(
      id: json['id'],
      employerId: employerId,
      title: json['title'] ?? 'Untitled Task',
      companyName: json['company_name'] ?? 'Unknown',
      locationName: json['location_name'] ?? 'Unknown Location',
      location: LatLng(
        (json['geo_lat'] ?? json['latitude'] ?? 0.0).toDouble(),
        (json['geo_lng'] ?? json['longitude'] ?? 0.0).toDouble(),
      ),
      payout: (json['payout'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance']?.toString() ?? '0 km',
      time: json['estimated_hours']?.toString() ?? '4',
      status: json['status'] ?? 'open',
      description: json['description'] ?? '',
      workersRequired: json['workers_required'] ?? 1,
      paymentType: json['payment_type'] ?? 'fixed',
      startTime: json['start_time'] != null ? DateTime.tryParse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      category: json['category'] ?? 'general',
      requirements: json['requirements'] ?? {},
      proofRequired: List<String>.from(json['proof_required'] ?? []),
      assignedTo: json['assigned_to'] is Map ? json['assigned_to']['id'] : json['assigned_to'],
      assignedWorkerName: json['assigned_to'] is Map ? json['assigned_to']['full_name'] : null,
      assignedWorkerAvatar: json['assigned_to'] is Map ? json['assigned_to']['profile_picture_url'] : null,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      checkInPhoto: json['check_in_photo'],
      checkOutPhoto: json['check_out_photo'],
      liveLat: (json['live_lat'] as num?)?.toDouble(),
      liveLng: (json['live_lng'] as num?)?.toDouble(),
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated']) : null,
      inProgressPhotos: List<String>.from(json['in_progress_photos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': employerId,
      'title': title,
      'company_name': companyName,
      'location_name': locationName,
      'geo_lat': location.latitude,
      'geo_lng': location.longitude,
      'payout': payout,
      'estimated_hours': time,
      'status': status,
      'description': description,
      'workers_required': workersRequired,
      'payment_type': paymentType,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'category': category,
      'requirements': requirements,
      'proof_required': proofRequired,
      'assigned_to': assignedTo,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'check_in_photo': checkInPhoto,
      'check_out_photo': checkOutPhoto,
      'live_lat': liveLat,
      'live_lng': liveLng,
      'last_updated': lastUpdated?.toIso8601String(),
      'in_progress_photos': inProgressPhotos,
    };
  }
}
