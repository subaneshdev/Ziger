import '../../models/review_model.dart';
import '../../services/api_service.dart';

abstract class ReviewRepository {
  Future<Review> submitReview(String taskId, int rating, String comment);
  Future<List<Review>> getUserReviews(String userId);
}

class ApiReviewRepository implements ReviewRepository {
  final ApiService _apiService;

  ApiReviewRepository(this._apiService);

  @override
  Future<Review> submitReview(String taskId, int rating, String comment) async {
    final response = await _apiService.post(
      '/reviews/$taskId',
      {
        'rating': rating,
        'comment': comment,
      },
    );
    return Review.fromJson(response.data);
  }

  @override
  Future<List<Review>> getUserReviews(String userId) async {
    final response = await _apiService.get('/reviews/user/$userId');
    return (response.data as List).map((e) => Review.fromJson(e)).toList();
  }
}
