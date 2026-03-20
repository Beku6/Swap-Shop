import '../repositories/notification_repository.dart';

class MarkNotificationRead {
  final NotificationRepository _repository;

  const MarkNotificationRead(this._repository);

  Future<void> call({
    required String userId,
    required String notificationId,
  }) {
    return _repository.markAsRead(userId: userId, notificationId: notificationId);
  }
}
