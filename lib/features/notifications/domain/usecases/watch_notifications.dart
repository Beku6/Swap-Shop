import '../../../shared/domain/models/app_notification.dart';
import '../repositories/notification_repository.dart';

class WatchNotifications {
  final NotificationRepository _repository;

  const WatchNotifications(this._repository);

  Stream<List<AppNotification>> call(String userId) {
    return _repository.watchNotifications(userId);
  }
}
