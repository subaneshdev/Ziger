import 'user_profile.dart';
import 'task_model.dart';

class Review {
  final String id;
  final String taskId;
  final String reviewerId; // Or UserProfile if you nest it
  final String revieweeId; // Or UserProfile if you nest it
  final int rating;
  final String? comment;
  final DateTime createdAt;

  // Optional: full objects if your backend returns them nested
  final UserProfile? reviewer;
  final UserProfile? reviewee;

  Review({
    required this.id,
    required this.taskId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewer,
    this.reviewee,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      taskId: json['task'] is Map ? json['task']['id'] : (json['task_id'] ?? ''),
      reviewerId: json['reviewer'] is Map ? json['reviewer']['id'] : (json['reviewer_id'] ?? ''),
      revieweeId: json['reviewee'] is Map ? json['reviewee']['id'] : (json['reviewee_id'] ?? ''),
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      reviewer: json['reviewer'] is Map ? UserProfile.fromJson(json['reviewer']) : null,
      reviewee: json['reviewee'] is Map ? UserProfile.fromJson(json['reviewee']) : null,
    );
  }
}
