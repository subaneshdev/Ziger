
import 'package:ziggers/models/user_profile.dart';
import 'package:ziggers/models/task_model.dart';

class TaskApplication {
  final String id;
  final Task? task; // Optional to avoid recursion or if backend sends ID only
  final String taskId;
  final UserProfile worker;
  final double? bidAmount;
  final String? pitchMessage;
  final String status;
  final DateTime createdAt;

  TaskApplication({
    required this.id,
    this.task,
    required this.taskId,
    required this.worker,
    this.bidAmount,
    this.pitchMessage,
    required this.status,
    required this.createdAt,
  });

  factory TaskApplication.fromJson(Map<String, dynamic> json) {
    return TaskApplication(
      id: json['id'] ?? '',
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      taskId: json['task'] != null ? json['task']['id'] : (json['taskId'] ?? ''),
      worker: UserProfile.fromJson(json['worker']),
      bidAmount: json['bidAmount'] != null ? (json['bidAmount'] as num).toDouble() : null,
      pitchMessage: json['pitchMessage'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
