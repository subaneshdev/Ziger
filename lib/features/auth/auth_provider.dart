import 'package:flutter/material.dart';
import 'package:ziggers/services/api_service.dart';
import '../../services/supabase_service.dart'; // Keep for some utilities if needed, or remove if unused
import '../../models/user_profile.dart';
import 'dart:io';
import '../../data/repositories/kyc_repository.dart';
import '../../data/repositories/api_kyc_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/api_user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final SupabaseService _supabase = SupabaseService(); // Used for storage upload in KYC Repo
  bool _isLoading = false;
  UserProfile? _userProfile;

  bool get isAuthenticated => _userProfile != null; // Simpler check, or check token existence
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;
  
  // Shortcuts
  String? get role => _userProfile?.role;
  bool get isKycApproved => _userProfile?.kycStatus == 'approved';
  bool get isKycPending => _userProfile?.kycStatus == 'pending';
  String? get kycStatus => _userProfile?.kycStatus;

  // Repository
  late final KycRepository _kycRepository;
  late final UserRepository _userRepository;

  AuthProvider() {
    _kycRepository = ApiKycRepository();
    _userRepository = ApiUserRepository();
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    final token = await _api.getToken();
    final userId = await _api.getUserId();

    if (token != null && userId != null) {
      await _fetchProfile(userId);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    notifyListeners();
    final formattedPhone = '+91$phone'; // Hardcoded country code for now
    debugPrint('Attempting to send OTP to: $formattedPhone via Backend');
    
    try {
      await _api.post('/auth/send-otp', {'mobile': formattedPhone});
      debugPrint('OTP Sent successfully');
      return true;
    } catch (e) {
      debugPrint('Send OTP Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();
    final formattedPhone = '+91$phone';
    try {
      final response = await _api.post('/auth/verify-otp', {
        'mobile': formattedPhone,
        'otp': otp
      });
      
      debugPrint('Verify Response: $response'); // DEBUG: Print full response

      if (response != null) {
         // Handle both snake_case (Spring default with property) and camelCase (Java default)
         String? token = response['access_token'] ?? response['accessToken'];
         String? userId = response['profile'] != null ? response['profile']['id']?.toString() : null;

         if (token != null && userId != null) {
             await _api.setToken(token);
             await _api.setUserId(userId);
             
             // Use profile from response directly
             if (response['profile'] != null) {
                _userProfile = UserProfile.fromJson(response['profile']);
             } else {
                await _fetchProfile(userId);
             }
             return true;
         }
      }
      return false;
    } catch (e) {
      debugPrint('Verify OTP Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final profile = await _userRepository.fetchProfile(userId);
      if (profile != null) {
        _userProfile = profile;
        debugPrint('Profile fetched: ${_userProfile?.toJson()}');
      } else {
        debugPrint('Profile returned null');
        _userProfile = null;
      }
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
      _userProfile = null;
    }
  }

  Future<void> setRole(String role) async {
    if (_userProfile == null) return;
    
    try {
      await _userRepository.updateRole(_userProfile!.id, role);
      await _fetchProfile(_userProfile!.id); 
      notifyListeners();
    } catch (e) {
      debugPrint('Set Role Error: $e');
    }
  }

  Future<bool> submitKyc(Map<String, dynamic> data, {File? idFront, File? idBack, File? selfie, File? profileImage}) async {
    if (_userProfile == null) return false;
    _isLoading = true;
    notifyListeners();
    debugPrint('AuthProvider: Starting KYC Submit...');

    try {
      debugPrint('AuthProvider: Calling Repository...');
      final result = await _kycRepository.submitKyc(
        data: data,
        idFront: idFront,
        idBack: idBack,
        selfie: selfie,
        profileImage: profileImage,
      );
      
      if (result != null) {
        debugPrint('AuthProvider: KYC Success. Updating Profile.');
        _userProfile = UserProfile.fromJson(result);
        notifyListeners();
        return true;
      }
      debugPrint('AuthProvider: KYC Failed (Result null).');
      return false;
      
    } catch (e) {
      debugPrint('AuthProvider: KYC Submit Error: $e');
      return false;
    } finally {
      debugPrint('AuthProvider: Stopping Loading.');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _userProfile = null;
    await _api.clearSession();
    _supabase.signOut();
    notifyListeners();
  }
}
