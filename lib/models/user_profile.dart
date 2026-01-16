
class UserProfile {
  final String id;
  final String? role; // 'worker', 'employer', or null
  final String kycStatus; // 'pending', 'approved', 'rejected'
  final double walletBalance;
  final int trustScore;
  final String? idCardNumber;
  final String? fullName;
  final String? email;
  final String? profilePhotoUrl;
  
  // New Fields
  final DateTime? dob;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? idType;
  final String? idCardFrontUrl;
  final String? idCardBackUrl;
  final String? selfieUrl;
  final double? currentLat;
  final double? currentLng;

  // Stats
  final int responseRate;
  final double rating;
  final int completedOrders;
  final int activeOrders;

  UserProfile({
    required this.id,
    this.role,
    required this.kycStatus,
    required this.walletBalance,
    required this.trustScore,
    this.idCardNumber,
    this.fullName,
    this.email,
    this.profilePhotoUrl,
    this.dob,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.idType,
    this.idCardFrontUrl,
    this.idCardBackUrl,
    this.selfieUrl,
    this.currentLat,
    this.currentLng,
    this.responseRate = 0,
    this.rating = 0.0,
    this.completedOrders = 0,
    this.activeOrders = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      role: json['role'], 
      kycStatus: json['kyc_status'] ?? 'pending',
      walletBalance: (json['wallet_balance'] ?? 0).toDouble(),
      trustScore: json['trust_score'] ?? 100,
      idCardNumber: json['id_card_number'],
      fullName: json['full_name'],
      email: json['email'],
      profilePhotoUrl: json['profile_photo_url'] ?? json['avatar_url'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      gender: json['gender'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      idType: json['id_type'],
      idCardFrontUrl: json['id_card_front_url'],
      idCardBackUrl: json['id_card_back_url'],
      selfieUrl: json['selfie_url'],
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLng: (json['current_lng'] as num?)?.toDouble(),
      responseRate: json['response_rate'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      completedOrders: json['completed_orders'] ?? 0,
      activeOrders: json['active_orders'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'kyc_status': kycStatus,
      'wallet_balance': walletBalance,
      'trust_score': trustScore,
      'full_name': fullName,
      'email': email,
      'profile_photo_url': profilePhotoUrl,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'id_type': idType,
      'id_card_front_url': idCardFrontUrl,
      'id_card_back_url': idCardBackUrl,
      'selfie_url': selfieUrl,
      'current_lat': currentLat,
      'current_lng': currentLng,
    };
  }
}
