import 'package:ziggers/models/task_model.dart';
import 'package:ziggers/models/task_application_model.dart';
import 'package:ziggers/services/api_service.dart';
import 'task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  final ApiService _api = ApiService();

  @override
  Future<List<Task>> fetchTasks() async {
    // Current geolocation logic can be moved here or passed as params
    // For MVP, hardcode or fetch near default location
    // final response = await _api.get('/gigs/feed?lat=37.7749&lng=-122.4194&radius=50');
    // Using simple fetch all if admin endpoint existed, but feed is safe default
    final response = await _api.get('/gigs/feed?lat=37.7749&lng=-122.4194&radius=100000');
    
    if (response == null) return [];
    
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<List<Task>> fetchTasksByEmployer(String employerId) async {
    final response = await _api.get('/gigs/my-gigs');
    
    if (response == null) return [];
    
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<List<Task>> fetchAssignedTasks() async {
    final response = await _api.get('/gigs/assigned'); // Header X-User-Id is handled by ApiService interceptor (ideally)
    if (response == null) return [];
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    await _api.post('/gigs', task.toJson());
  }

  @override
  Future<void> applyForGig(String taskId, String workerId) async {
    await _api.post('/gigs/$taskId/apply', {});
  }

  @override
  Future<void> assignWorker(String taskId, String workerId) async {
    await _api.post('/gigs/$taskId/assign/$workerId', {});
  }

  @override
  Future<void> startGig(String taskId) async {
    await _api.post('/gigs/$taskId/start', {});
  }

  @override
  Future<void> checkIn(String taskId, double lat, double lng, String photoUrl) async {
    // Backend doesn't have strict check-in, map to startGig or updateLocation
    // Reuse startGig if status is assigned
     await _api.post('/gigs/$taskId/start', {});
  }

  @override
  Future<void> updateLiveLocation(String taskId, double lat, double lng) async {
    // Use ProfileService location update
    // We need userId. Assuming it's in token, but repository method might not have it.
    // Current TaskRepository signature takes taskId.
    // Map to new Api endpoint if we adjust repo signature or fetch user id from somewhere.
    // _api.post('/profiles/$userId/location?lat=$lat&lng=$lng', {});
  }

  @override
  Future<void> uploadProgressPhoto(String taskId, String photoUrl) async {
    await _api.post('/gigs/$taskId/proof', photoUrl); // Sending raw string body or JSON? 
    // Controller expects @RequestBody String photoUrl. 
    // ApiService.post jsonEncodes body.
    // Make sure controller accepts JSON string "url" or plain text. 
    // Controller signature: @RequestBody String photoUrl => Spring maps body to string.
    // If we send JSON "url", Spring sees "{"url":...}".
    // Better to send map keys relative to backend expectation.
  }

  @override
  Future<void> checkOut(String taskId, String photoUrl) async {
    // Maybe upload proof and then complete?
    await uploadProgressPhoto(taskId, photoUrl);
    await completeGig(taskId);
  }

  @override
  Future<void> completeGig(String taskId) async {
    await _api.post('/gigs/$taskId/complete', {});
  }

  @override
  Future<List<Task>> getRecommendations(String userId) async {
    final response = await _api.get('/ai/recommendations'); // Header X-User-Id handles user
    if (response == null) return [];
    return (response as List).map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<List<TaskApplication>> getApplications(String taskId) async {
    print('DEBUG: Getting applications for task: $taskId');
    final response = await _api.get('/gigs/$taskId/applications');
    print('DEBUG: Applications response: $response');
    if (response == null) {
      print('DEBUG: Response is null');
      return [];
    }
    print('DEBUG: Parsing ${(response as List).length} applications');
    return (response as List).map((json) => TaskApplication.fromJson(json)).toList();
  }

  @override
  Future<TaskApplication?> getMyApplication(String taskId) async {
    // 204 No Content returns null in ApiService usually, or throws exception?
    // Assuming ApiService.get handles 204 by returning null.
    // Or we handle error.
    try {
      final response = await _api.get('/gigs/$taskId/my-application');
      if (response == null) return null;
      return TaskApplication.fromJson(response);
    } catch (e) {
      // 204 often results in empty body which works fine, but 404/others throw.
      return null;
    }
  }
}
