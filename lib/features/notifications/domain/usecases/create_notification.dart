import '../../../shared/domain/models/app_notification.dart';
import '../repositories/notification_repository.dart';

class CreateNotification {
  final NotificationRepository _repository;

  const CreateNotification(this._repository);

  Future<void> call(AppNotification notification) {
    return _repository.createNotification(notification);
  }
}
