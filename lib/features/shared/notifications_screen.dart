import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/notification_repository.dart';
import '../../models/notification_model.dart';
import '../../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationRepo = context.read<NotificationRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: notificationRepo.getMyNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(notification.message),
                trailing: Text(
                  '${notification.createdAt.day}/${notification.createdAt.month}',
                  style: const TextStyle(color: Colors.grey),
                ),
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? Colors.grey[300] : AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.notifications,
                    color: notification.isRead ? Colors.grey : AppColors.primary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
