import '../../models/notification_model.dart';
import '../../services/api_service.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getMyNotifications();
}

class ApiNotificationRepository implements NotificationRepository {
  final ApiService _apiService;

  ApiNotificationRepository(this._apiService);

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _apiService.get('/notifications');
    return (response.data as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }
}
