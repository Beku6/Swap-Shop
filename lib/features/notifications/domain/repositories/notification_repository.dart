import '../../../shared/domain/models/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String userId);
  Future<List<AppNotification>> fetchNotifications(String userId);
  Future<void> createNotification(AppNotification notification);
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });
  Future<void> upsertDeviceToken({
    required String userId,
    required String token,
    required String platform,
  });
}
