
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart'; // Adjust path if needed
import 'user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final supabaseData = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (supabaseData != null) {
        return UserProfile.fromJson(supabaseData);
      }
      return null;
    } catch (e) {
      // Log error (debugPrint not available in pure dart, but passing up)
      rethrow;
    }
  }

  @override
  Future<UserProfile?> createProfile(String userId) async {
    final updates = {
      'id': userId,
      'role': null, // Default to null so user can select role
      'kyc_status': 'pending',
      'wallet_balance': 0,
      'trust_score': 100,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await _client.from('profiles').insert(updates);
      return UserProfile.fromJson(updates);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateRole(String userId, String role) async {
    try {
      await _client
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
