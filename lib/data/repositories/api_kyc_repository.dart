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
    
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    String? idFrontUrl;
    String? idBackUrl;
    String? selfieUrl;

    if (idFront != null) {
      idFrontUrl = await _supabase.uploadKycDocument(userId, idFront.path, 'id_front');
    }
    if (idBack != null) {
      idBackUrl = await _supabase.uploadKycDocument(userId, idBack.path, 'id_back');
    }
    if (selfie != null) {
      selfieUrl = await _supabase.uploadKycDocument(userId, selfie.path, 'selfie');
    }
    
    // 2. Construct JSON for Backend
    // 2. Construct JSON for Backend
    final kycRequest = {
      // Basic
      'fullName': data['full_name'], 
      'dob': data['date_of_birth'], // Updated key to match backend (check DTO if it's 'dob' or 'dateOfBirth'. DTO has 'LocalDate dob', JSON usually expects 'dob')
      'gender': data['gender'],
      'address': data['address'],
      'city': data['city'],
      'state': data['state'],
      'pincode': data['pincode'],
      
      // Identity
      'idType': data['id_type'],
      'idCardNumber': data['id_card_number'],
      'idCardFrontUrl': idFrontUrl,
      'idCardBackUrl': idBackUrl,
      'selfieUrl': selfieUrl,
      'profilePhotoUrl': profileImage != null ? await _supabase.uploadKycDocument(userId, profileImage.path, 'profile_photo') : null,

      // Bank (Worker)
      'bankAccountName': data['bank_account_name'],
      'bankAccountNumber': data['bank_account_number'],
      'bankIfsc': data['bank_ifsc'],
      'upiId': data['upi_id'],

      // Work Prefs (Worker)
      'gigTypes': data['work_preferences']?['types'], // List<String>
      'workRadius': data['work_preferences']?['radius_km'],
      'willingToTravel': data['work_preferences']?['willing_to_travel'],
      // 'availableTimeSlots': ... (not implemented in UI yet but good to have mapping ready if added)

      // Business (Employer)
      'employerType': data['employer_type'],
      'businessName': data['business_name'],
      'natureOfWork': data['nature_of_work'],
      'businessAddress': data['business_address'],
      
      // Payment (Employer)
      'paymentMethod': data['payment_method'],
      'billingName': data['billing_name'],
      'gstNumber': data['gst_number'],
      'invoiceAddress': data['invoice_address'],
      
      'isAgreedToTerms': data['is_agreed_to_terms'],
    };

    // 3. Call Backend
    final response = await _api.post('/profiles/$userId/kyc', kycRequest);
    return response as Map<String, dynamic>?;
  }
}
