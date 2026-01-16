import 'package:ziggers/models/user_profile.dart';
import 'package:ziggers/services/api_service.dart';
import 'user_repository.dart';

class ApiUserRepository implements UserRepository {
  final ApiService _api = ApiService();

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final json = await _api.get('/profiles/$userId');
      if (json == null) return null;
      return UserProfile.fromJson(json);
    } catch (e) {
      // Handle 404 or other errors
      return null;
    }
  }

  @override
  Future<UserProfile?> createProfile(String userId) async {
    // Backend creates profile automatically on OTP verification.
    // We just return fetchProfile.
    return fetchProfile(userId);
  }

  @override
  Future<void> updateRole(String userId, String role) async {
    await _api.put('/profiles/$userId/role', {'role': role});
  }
}
