import '../domain/services/push_permission_handler.dart';
import '../../notifications/data/push_notification_service.dart';

class PushPermissionHandlerAdapter implements PushPermissionHandler {
  const PushPermissionHandlerAdapter(this._service);

  final PushNotificationService _service;

  @override
  Future<bool> isPermissionGranted() => _service.isPermissionGranted();

  @override
  Future<bool> requestPermissionIfNeeded() =>
      _service.requestPermissionIfNeeded();

  @override
  Future<void> setPushEnabled(bool enabled) => _service.setPushEnabled(enabled);

  @override
  Future<void> syncCurrentToken() => _service.syncCurrentToken();
}
