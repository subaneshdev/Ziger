import 'dart:io';
import 'package:ziggers/services/api_service.dart';
import 'package:ziggers/services/supabase_service.dart'; // Keep for storage
import 'kyc_repository.dart';

class ApiKycRepository implements KycRepository {
  final ApiService _api = ApiService();
  final SupabaseService _supabase = SupabaseService(); 

  @override
  Future<Map<String, dynamic>?> submitKyc({
    required Map<String, dynamic> data,
    File? idFront,
    File? idBack,
    File? selfie,
    File? profileImage, // Not used in backend standard KYC flow usually but might be needed
  }) async {
    
    // 1. Upload Images to Supabase Storage (or any storage)
    // We assume SupabaseService.uploadKycDocument exists (it does)
    
    // We need userId. Pass it in data or fetch?
    // Data likely has 'id' or we need to pass it. 
    // Usually repository methods should take entity ID. 
    // Assuming 'data' contains fields. We need user ID to construct path and call API.
    // But wait, the repository interface doesn't take userId. 
    // 'data' probably implies it or we rely on Auth token (but backend needs path param).
    // Let's assume we extract or pass it. 
    
    // Fix: Repository signature is: submitKyc({required data, ...})
    // We'll rely on ApiService to have token, but URL needs ID.
    // Getting ID from ApiService token/stored? Or SupabaseService.currentUser.id?
    // Let's use SupabaseService.currentUser?.id as fallback or pass in data['id'].
    
    final userId = await _api.getUserId();
    if (userId == null) throw Exception("User not logged in (Backend ID missing)");

    // Parallel Uploads to speed up
    final idFrontFuture = idFront != null ? _supabase.uploadKycDocument(userId, idFront.path, 'id_front') : Future.value(null);
    final idBackFuture = idBack != null ? _supabase.uploadKycDocument(userId, idBack.path, 'id_back') : Future.value(null);
    final selfieFuture = selfie != null ? _supabase.uploadKycDocument(userId, selfie.path, 'selfie') : Future.value(null);
    final profileFuture = profileImage != null ? _supabase.uploadKycDocument(userId, profileImage.path, 'profile_photo') : Future.value(null);

    final results = await Future.wait([idFrontFuture, idBackFuture, selfieFuture, profileFuture]);
    
    final idFrontUrl = results[0];
    final idBackUrl = results[1];
    final selfieUrl = results[2];
    final String? profilePhotoUrl = results[3];
    
    // 2. Construct JSON for Backend
    // 2. Construct JSON for Backend
    final kycRequest = {
      // Basic
      'full_name': data['full_name'], 
      'dob': data['date_of_birth'], 
      'gender': data['gender'],
      'address': data['address'],
      'city': data['city'],
      'state': data['state'],
      'pincode': data['pincode'],
      
      // Identity
      'id_type': data['id_type'],
      'id_card_number': data['id_card_number'],
      'id_card_front_url': idFrontUrl,
      'id_card_back_url': idBackUrl,
      'selfie_url': selfieUrl,
      'profile_photo_url': profilePhotoUrl, // if passed

      // Bank (Worker)
      'bank_account_name': data['bank_account_name'],
      'bank_account_number': data['bank_account_number'],
      'bank_ifsc': data['bank_ifsc'],
      'upi_id': data['upi_id'],

      // Work Prefs (Worker)
      'gig_types': data['work_preferences']?['types'], 
      'work_radius': data['work_preferences']?['radius_km'],
      'willing_to_travel': data['work_preferences']?['willing_to_travel'],
      // 'available_time_slots': ... 

      // Business (Employer)
      'employer_type': data['employer_type'],
      'business_name': data['business_name'],
      'nature_of_work': data['nature_of_work'],
      'business_address': data['business_address'],
      
      // Payment (Employer)
      'payment_method': data['payment_method'],
      'billing_name': data['billing_name'],
      'gst_number': data['gst_number'],
      'invoice_address': data['invoice_address'],
      
      'is_agreed_to_terms': data['is_agreed_to_terms'],
    };

    // 3. Call Backend
    final response = await _api.post('/profiles/$userId/kyc', kycRequest);
    return response as Map<String, dynamic>?;
  }
}
