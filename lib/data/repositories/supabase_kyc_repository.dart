import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart'; // To reuse existing service if needed or just use Supabase.instance
import 'kyc_repository.dart';

class SupabaseKycRepository implements KycRepository {
  final SupabaseClient _client;

  SupabaseKycRepository(this._client);

  @override
  Future<Map<String, dynamic>?> submitKyc({
    required Map<String, dynamic> data,
    File? idFront,
    File? idBack,
    File? selfie,
    File? profileImage,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      String? frontUrl;
      String? backUrl;
      String? profileImageUrl;

      // 1. Upload Images using existing SupabaseService logic
      final supabaseService = SupabaseService();
      
      if (idFront != null) {
        frontUrl = await supabaseService.uploadKycDocument(userId, idFront.path, 'front');
      }
      if (idBack != null) {
        backUrl = await supabaseService.uploadKycDocument(userId, idBack.path, 'back');
      }
      if (profileImage != null) {
        // Using same upload method but tagging as 'profile'
        profileImageUrl = await supabaseService.uploadKycDocument(userId, profileImage.path, 'profile_avatar');
      }

      // 2. Call Edge Function
      final payload = {
        ...data,
        'id_card_front_url': frontUrl,
        'id_card_back_url': backUrl,
        'profile_image_url': profileImageUrl,
      };

      final session = _client.auth.currentSession;
      final token = session?.accessToken;
      
      if (token == null) throw Exception('No active session');

      final response = await _client.functions.invoke(
        'submit-kyc-',
        body: payload,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        final errorMsg = response.data is Map ? response.data['error'] : 'Unknown Error';
        throw Exception('Function Error ${response.status}: $errorMsg');
      }
    } catch (e) {
      print('Repository Error: $e');
      // Rethrow to let UI know
      throw Exception('Submission Failed: $e');
    }
  }
}
