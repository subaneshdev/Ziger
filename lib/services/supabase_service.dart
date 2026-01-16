
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  // Auth Helpers
  User? get currentUser => client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<void> signInWithOtp(String phone) async {
    // Triggers Supabase to send SMS via Twilio (if configured)
    await client.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<AuthResponse> verifyOtp(String phone, String token) async {
    return await client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> submitKycDetails(String userId, Map<String, dynamic> data) async {
    await client.from('profiles').update({
      ...data,
      'kyc_status': 'pending', 
    }).eq('id', userId);
  }

  Future<String> uploadKycDocument(String userId, String filePath, String docType) async {
      try {
        final fileName = '$userId/${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        // Need to import dart:io
        // await client.storage.from('kyc_documents').upload(fileName, File(filePath));
        // return client.storage.from('kyc_documents').getPublicUrl(fileName);
        
        // Simulating upload for now
        await Future.delayed(const Duration(milliseconds: 500));
        return 'https://mock-storage.com/$fileName';
      } catch (e) {
        return 'https://via.placeholder.com/300?text=$docType';
      }
  }

  Future<List<Map<String, dynamic>>> getPendingKycUsers() async {
    return await client
        .from('profiles')
        .select()
        .eq('kyc_status', 'pending');
  }

  Future<void> updateKycStatus(String userId, String status) async {
    await client
        .from('profiles')
        .update({'kyc_status': status})
        .eq('id', userId);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
