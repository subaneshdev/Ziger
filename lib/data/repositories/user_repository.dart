
import '../../models/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile?> fetchProfile(String userId);
  Future<UserProfile?> createProfile(String userId);
  Future<void> updateRole(String userId, String role);
}
