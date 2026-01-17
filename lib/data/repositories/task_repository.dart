import '../../models/task_model.dart';
import '../../models/task_application_model.dart';

abstract class TaskRepository {
  Future<List<Task>> fetchTasks();
  Future<List<Task>> fetchTasksByEmployer(String employerId);
  Future<void> createTask(Task task);
  
  // Lifecycle Methods
  Future<void> applyForGig(String taskId, String workerId);
  Future<void> assignWorker(String taskId, String workerId);
  Future<void> startGig(String taskId);
  Future<void> checkIn(String taskId, double lat, double lng, String photoUrl);
  Future<void> updateLiveLocation(String taskId, double lat, double lng);
  Future<void> uploadProgressPhoto(String taskId, String photoUrl);
  Future<void> checkOut(String taskId, String photoUrl);
  Future<void> completeGig(String taskId);
  
  // AI Features
  Future<List<Task>> getRecommendations(String userId);

  Future<List<TaskApplication>> getApplications(String taskId);
  Future<List<Task>> fetchTasksByWorker(String workerId);
}
