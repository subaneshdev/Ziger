import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';
import 'task_repository.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _supabase;

  SupabaseTaskRepository(this._supabase);

  @override
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _supabase.from('tasks').select();
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error to avoid dummy data, logs can be added if needed
      // Assuming table might not exist or be empty
      return []; 
    }
  }
  @override
  Future<List<Task>> fetchTasksByEmployer(String employerId) async {
    try {
      print('DEBUG: Fetching tasks for employer_id (created_by): $employerId');
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('created_by', employerId); 
      print('DEBUG: Response length: ${(response as List).length}');
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('DEBUG: Error fetching tasks: $e');
      return [];
    }
  }

  @override
  Future<void> createTask(Task task) async {
    print('DEBUG: Creating task with ID: ${task.id} for employer: ${task.employerId}');
     try {
       await _supabase.from('tasks').insert(task.toJson());
       print('DEBUG: Task created successfully');
     } catch (e) {
       print('DEBUG: Error creating task: $e');
       rethrow;
     }
  }

  @override
  Future<void> applyForGig(String taskId, String workerId) async {
    await _supabase.from('task_applications').insert({
      'task_id': taskId,
      'worker_id': workerId,
      'status': 'pending', 
    });
    // Update task status to show there are applicants? Optional.
  }

  @override
  Future<void> assignWorker(String taskId, String workerId) async {
    await _supabase.from('tasks').update({
      'assigned_to': workerId,
      'status': 'assigned',
    }).eq('id', taskId);
    
    // Also update application status
    await _supabase.from('task_applications').update({
      'status': 'accepted',
    }).eq('task_id', taskId).eq('worker_id', workerId);
  }

  @override
  Future<void> startGig(String taskId) async {
    await _supabase.from('tasks').update({
      'status': 'in_progress',
      'started_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> checkIn(String taskId, double lat, double lng, String photoUrl) async {
    await _supabase.from('tasks').update({
      'check_in_photo': photoUrl,
      'live_lat': lat,
      'live_lng': lng,
      'last_updated': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> updateLiveLocation(String taskId, double lat, double lng) async {
    await _supabase.from('tasks').update({
      'live_lat': lat,
      'live_lng': lng,
      'last_updated': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> uploadProgressPhoto(String taskId, String photoUrl) async {
    // Determine existing photos first or use Postgres append if possible.
    // Ideally: update tasks set in_progress_photos = in_progress_photos || '["url"]'::jsonb where id = ...
    // But supabase-flutter might not expose raw SQL easily for updates without rpc.
    // Optimization: Fetch current, append, update.
    
    final response = await _supabase.from('tasks').select('in_progress_photos').eq('id', taskId).single();
    List<String> current = List<String>.from(response['in_progress_photos'] ?? []);
    current.add(photoUrl);
    
    await _supabase.from('tasks').update({
      'in_progress_photos': current,
      'last_updated': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> checkOut(String taskId, String photoUrl) async {
    await _supabase.from('tasks').update({
      'status': 'review',
      'check_out_photo': photoUrl,
      'last_updated': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> completeGig(String taskId) async {
    await _supabase.from('tasks').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }
}
